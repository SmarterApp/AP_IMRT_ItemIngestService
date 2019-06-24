# Items aren't Syncing

[Go Back](../README.md)

## Item Sync General Info

Item Ingest Service relies on webhooks within the Gitlab Itembank to know when an item changes.  Due to load on Gitlab webhooks may be missed or not processed for other reasons.  To make sure that IMRT always has the latest changes there is an endpoint one can use to manually sync the system.  This should be done during off hours because it does put load onto Gitlab, and the IMRT deployment provides a Kubernetes Cron deployment which can be configured and deployed with IMRT to run this periodically.

More information can be found [here](exec-item-sync.md)


## What if you're getting reports that items are not syncing?

### Same day
If the change has been less that 24 hours and it isn't an emergency you may just be able to wait until the next day since the sync job will run during off hours.  However, if the item must be synced immediately one can follow the steps under "sync a single item" section on the [synchornization process page](exec-item-sync.md).

### Multiple days of not syncing
It may be that a single item has not synced in some time.  This probably means that either this is an issue in the software or that the off-hours sync process isn't running properly.

The following are good steps to follow

1. Check Graylog for any ERROR level logs
	* The errors may indicate why the item isn't syncing properly
2. Check if the sync job is running properly

### Log messages when a job is hung
When one tries to start a job that is already running you will see the following error:
```
2019-06-15 04:00:08.461 ERROR 5 --- [nio-9081-exec-8] o.o.a.i.i.c.GlobalExceptionHandler       : IMRT_ERROR: A job is already running
org.springframework.batch.core.repository.JobExecutionAlreadyRunningException: A job execution for this job is already running: JobInstance: id=1, version=0, Job=[itemSynchronizationJob]
```

This means that either the nightly sync job has already started or that the previous job failed for an unknown reason.  This should be investigated to determine the cause of the failure.  To restart the job you will need to abandon the job.

## Check if the sync job is running properly

**NOTE:** This section assumes you have verified the cron job is running in the Kubernetes environment or the cron job you created yourself is functioning as expected.  Recommend not modifying any jobs less that 24 hours old to make sure you're not impacting a running job.

The ingest service uses [Spring Batch](https://docs.spring.io/spring-batch/trunk/reference/html/) for its sync and migration jobs.  In rare occurrences the job execution data can get dirty and the only way to fix this is manual intervention.  The only times we have seen this occur is when the server is unexpectadly shutdown/restarted while the job is processing which should be a very rare occurrence.  The following steps can be used to verify if the job is in a dirty step and the steps to correct the issue.

### Check the Database Tables

You will need to have access to the IMRT database used by the system.  There are many tables for Spring batch but the one you'll want to look at is `batch_job_execution`.  Each row in this table corresponds to a job that is/was run.

Run the following SQL: 
<pre>
select 
  job\_execution\_id, 
  job\_instance\_id, 
  start\_time, 
  end\_time, 
  status, 
  exit\_message 
from batch\_job\_execution 
order by start\_time desc;
</pre>

| Column | Description | Notes |
| ------ | ----------- | ----- |
| `job_execution_id` | The unique id for the job execution | |
| `job_instance_id` | Each job type has an instance id. | This field is used to "abandon" jobs|
| `start_time` | When the job execution was started | |
| `end_time` | When the job execution completed | If this does not have a value it means the job most likely is hung and you will need to reset it. |
| `status` | The status of the job | Anything non-null value other than `STARTED` means the job has completed (success or error) |
| `exit_message` | All IMRT jobs provide metadata about the job run stored in this table | Successful jobs will have metadata here.  Unexpected Exceptions are also logged in this column |

If the job execution has a `start_time` but no `end_time` this means the job is in a dirty state and will need to be "reset" so that it can run again.  There are two ways to fix this with the preference to not to directly edit existing tables.

#### Abandon Job via API
The item ingest service has an API endpoint one can call that will abandon the job programitcally.  This is the recommended solution to reset the job as it ensures that the job is reset in the proper manner.  This will require you to have access to the Kubernetes pods.

1. Grab the `job_instance_id` for the job you want to reset.
1. Get the item ingest pod id by running `kubectl get po`
1. Exec into the pod: `kubectl exec -it <pod id> /bin/sh`
1. Run `curl -X PUT http://localhost:9081/abandon/{job_instance_id}`
	* So if the job instance id is 1 the url would be `curl -X PUT http://localhost:9081/abandon/1`

The endpoint will return a response whether the job was abandoned.  You can rerun the query above to double check, and the status should be `ABANDONED`.  This means the the next time the nightly sync job runs it will start again.

#### Abandon Job via DB tables
We've never seen an instance when the job cannot be abandoned by the endpoint, but in the rare instance that it cannot be reset you can do this manually running the following SQL.  You will need to use the `job_execution_id` when running the following SQL.

<pre>
-- ----------------------------------------------------------------------
-- Update the batch_step_execution table, indicating the job has finished
-- executing.
-- ----------------------------------------------------------------------
UPDATE
    batch_step_execution
SET
    status = 'ABANDONED',
    exit_code = 'ABANDONED',
    end_time = CURRENT_TIMESTAMP
WHERE
    job_execution_id = -- [the job_execution_id of the record that is incomplete]

-- ----------------------------------------------------------------------
-- Update the batch_job_execution table, indicating the job has finished
-- executing.
-- ----------------------------------------------------------------------
UPDATE
    batch_job_execution
SET
    status = 'ABANDONED',
    exit_code = 'ABANDONED',
    end_time = CURRENT_TIMESTAMP,
    exit_message = 'Marked anbandon by SQL'
WHERE
    job_execution_id = -- [the job_execution_id of the record that is incomplete]
</pre>
