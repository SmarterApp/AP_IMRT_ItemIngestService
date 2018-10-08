# Running and Monitoring the Item Data Migration Process

[Go Back](../README.md)

This document describes how to execute monitor and troubleshoot the [Item Data Migration Process](./item-migration.md) within an IMRT environment.

## Execution
To execute the Item Data Migration Process, create a `POST` call to the `/migrate` endpoint of the Item Ingest Service.  The easiest way to execute the Item Data Migration Process is from a pod within the IMRT Kubernetes environment.  Steps are shown below:

1. Log into a pod within the Kubernetes environment:  `kubectl exec -it <identifier of pod> /bin/sh`
2. Run `curl -i -X POST "http://ap-imrt-iis-service/migrate"`
3. If the job was started successfully, a `200 OK` status will be returned.  The response payload will contain the job execution id and the job's status:

	```json
	{"jobExecutionId":13,"name":"itemMigrationJob","status":"STARTING"}
	```

For additional details on Kubernetes services, refer to [this page](https://kubernetes.io/docs/concepts/services-networking/service/).

### Execution Outside of the Kubernetes Environment
The Item Data Migration Process can be called from outside the Kubernetes environment.  Follow these steps to do so:

* Get a bearer token from OpenAM:

	```
	curl -i -X POST \
	   -H "Content-Type:application/x-www-form-urlencoded" \
	   -d "grant_type=password" \
	   -d "username=[a user account registered within openam]" \
	   -d "password=[password for user specified in 'username' field]" \
	   -d "client_id=[client id registered in OpenAM]" \
	   -d "client_secret=[client secret for client id]" \
	 'https://[OpenAM domain]/auth/oauth2/access_token?realm=%2Fsbac'
    ```

* The response will appear similar to this:

	```json
	{
	  "scope": "cn givenName mail sbacTenancyChain sbacUUID sn",
	  "expires_in": 35999,
	  "token_type": "Bearer",
	  "refresh_token": "[redacted]",
	  "access_token": "[redacted]"
	}
	```

* Pass the `access_token` acquired from the previous step in header of the `POST` to the Item Ingest Service:

	```
	curl -i -X POST -H "Authorization: Bearer [access_token from previous step]" "http://[IMRT Item Ingest Service domain]/migrate"
	```

Example:

```
curl -i -X POST -H "Authorization: Bearer a-bearer-token-uuid" "http://imrt-example.com/migrate"
```

## Monitoring
The item data migration process writes information about its progres to the application's log file.  Details on the log entries that are recorded can be found [here](./logging.md).  There are two methods for monitoring the item data migration process as it runs:

### Follow Log Entries in Graylog
Documentation on how to query Graylog can be found [here](http://docs.graylog.org/en/2.4/pages/queries.html).

### Tail the Item Ingest Service Log Files in Kubernetes
To tail the log file on the Item Ingest Service pod in the Kubernetes cluster:

* Identify the Item Ingest Service pod:

	```
	$ kubectl get po | grep iis
	ap-imrt-iis-deployment-65c4cf5454-zrvs9     1/1       Running   0          3d

	```

* Tail the log file of the Item Ingest Service pod identified in the previous step:

	```
	$ kubectl logs -f ap-imrt-iis-deployment-65c4cf5454-zrvs9
	```

At this point, the pod's log file is being followed and details of the item synchronization process will be displayed.  The log entries that signify the item data migration process has started will appear similar to what is shown below:

```
2018-06-28 11:32:19.151  INFO 41003 --- [cTaskExecutor-1] o.s.b.c.l.s.SimpleJobLauncher            : Job: [SimpleJob: [name=itemMigrationJob]] launched with the following parameters: [{}]
2018-06-28 11:32:19.160  INFO 41003 --- [nio-8080-exec-1] uration$$EnhancerBySpringCGLIB$$ad8132c1 : IMRT_PERFOMRANCE: Method signature: ItemIngestJobController.migrate(), input args: [], elapsed time (in ms): 210
2018-06-28 11:32:19.170  INFO 41003 --- [cTaskExecutor-1] i.b.ItemIngestSingleJobExecutionListener : itemMigrationJob starting.  Job execution id: 6
2018-06-28 11:32:19.204  INFO 41003 --- [cTaskExecutor-1] o.s.b.c.j.SimpleStepHandler              : Executing step: [itemMigrationStep]

... processing of each item bank id occurs ...

2018-06-28 11:33:12.916  INFO 41003 --- [cTaskExecutor-1] i.b.ItemIngestSingleJobExecutionListener : itemMigrationJob Job complete.  Job execution id: 6, exit status code: COMPLETED, exit message: Total item bank ids: 111, number of errors encountered: 0
2018-06-28 11:33:12.918  INFO 41003 --- [cTaskExecutor-1] o.s.b.c.l.s.SimpleJobLauncher            : Job: [SimpleJob: [name=itemMigrationJob]] completed with the following parameters: [{}] and the following status: [COMPLETED]

```

The **Job execution id** recorded in the log file corresponds to the `job_execution_id` in the `batch_job_execution` table.

To get additional details written to the log file, update the configuration for Item Ingest Service to use the `DEBUG` level:

```yaml
logging:
  level:
    org.opentestsystem: DEBUG
```

## Troubleshooting

### Diagnosing Issues
If the Item Data Migration Process encounters an exception, the job execution's status will be set to **FAILED** in the `batch_job_execution` table.  Furthermore, the exception message and stack trace will be recorded in the `exit_message` column of the `batch_job_execution` table.  To view the exception message and stack trace, execute the following SQL:

```sql
SELECT
    job_execution_id,
    exit_code,
    exit_message
FROM
    batch_job_execution
WHERE
    job_execution_id = [the id of the job execution that failed];
```

**NOTE:** when using pgAdmin, the stack trace may not be visible in the results field (possibly due to not handling carriage returns/line feeds properly).  If using [pgAdmin](https://www.pgadmin.org/download/), try using `psql` to execute the SQL cited above.

### Resetting the Job
The Item Data Migration Process job may occasionally fail before completing.  For example, the Kubernetes pod hosting the process is restarted before the Item Data Migration Process job finishes.  If this happens, the Spring Batch metadata tables will indicate the job is still in progress.  The SQL below can be used to identify and update the job step and job execution that are not completed:

***NOTE:***  Perform a backup of the `imrt` database prior to executing _any_ of the `UPDATE` or `DELETE` statements below.

```sql
-- ----------------------------------------------------------------------
-- Identify records in the batch_step_execution table that do not have a
-- status and exit_code == COMPLETED
-- ----------------------------------------------------------------------
SELECT
    step_execution_id,
    job_execution_id,
    status,
    exit_code,
    start_time,
    end_time,
    last_updated
FROM
    batch_step_execution
WHERE
    status <> 'COMPLETED'
    OR exit_code <> 'COMPLETED';

-- ----------------------------------------------------------------------
-- Update the batch_step_execution table, indicating the job has finished
-- executing.
-- ----------------------------------------------------------------------
UPDATE
    batch_step_execution
SET
    status = 'COMPLETED',
    exit_code = 'COMPLETED',
    end_time = CURRENT_TIMESTAMP
WHERE
    step_execution_id = -- [the step_execution_id of the record that is incomplete]

-- ----------------------------------------------------------------------
-- Update the batch_job_execution table, indicating the job has finished
-- executing.
-- ----------------------------------------------------------------------
UPDATE
    batch_job_execution
SET
    status = 'COMPLETED',
    exit_code = 'COMPLETED',
    end_time = CURRENT_TIMESTAMP,
    exit_message = 'Marked complete by SQL'
WHERE
    job_execution_id = -- [the job_execution_id of the record that is incomplete]
```
If the SQL cited above does not resolve this issue, delete records from the Spring Batch metadata tables:

```sql
DELETE FROM batch_step_execution_context;
DELETE FROM batch_step_execution;
DELETE FROM batch_job_execution_context;
DELETE FROM batch_job_execution_params;
DELETE FROM batch_job_execution;
DELETE FROM batch_job_instance;
```
