# Running and Monitoring the Item Synchronization Process

[Go Back](../README.md)

This document describes how to execute monitor and troubleshoot the [Item Synchronization Process](./item-sync.md) within an IMRT environment.

## Sync All Items in the Item Bank
To execute the Item Synchronization Process, create a `POST` call to the `/sync` endpoint of the Item Ingest Service.  The easiest way to execute the Item Synchronization Process is from a pod within the IMRT Kubernetes environment.  Steps are shown below:

1. Log into a pod within the Kubernetes environment:  `kubectl exec -it <identifier of pod> /bin/sh`
2. Run `curl -i -X POST "http://ap-imrt-iis-service/sync"`
3. If the job was started successfully, a `200 OK` status will be returned.  The response payload will contain the job execution id and the job's status:

	```json
	{"jobExecutionId":6,"name":"itemSynchronizationJob","status":"STARTING"}
	```

For additional details on Kubernetes services, refer to [this page](https://kubernetes.io/docs/concepts/services-networking/service/).

### Sync All Items Outside of the Kubernetes Environment
The item synchronization process can be called from outside the Kubernetes environment, follow these steps:

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
	curl -i -X POST -H "Authorization: Bearer [access_token from previous step]" "http://[IMRT Item Ingest Service domain]/sync"
	```

Example:

```
curl -i -X POST -H "Authorization: Bearer a-bearer-token-uuid" "http://imrt-example.com/sync"
```

### Automating Item Synchronization Process Execution
The Item Synchronization Process can be scheduled to run at regular intervals (e.g. nightly after regular production hours).  A cron job can be created in the IMRT Kubernetes environment.  Shown below is an example of a cron job that configures the Item Synchronization Process at 9:00 AM UTC:

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: sync-job
spec:
  # Schedule to run at 9am UTC each day
  schedule: "0 9 * * *"
```

## Sync single item
There is also the ability to sync a single item.  This can be useful when users are reporting a single item isn't in sync and it needs to be updated asap.  Since this only syncs a single item this minimizes the load on Gitlab.

The same steps above should be referenced as far as how to call the system.  The difference is in the URL that you want to call. IMRT works on Gitlab project ids so the item itself will not work.  You must provide the Gitlab project id in the URL.  The steps below document how to get the project id with the last step containing the URL to call for the sync itself.

1. Log into your gitlab instance
1. Find the item's project in gitlab.
	* Normally, this is in something like `gitlab url/iat-prod/<item-id>`
1. Once on the project page go to the "Settings" page for the project. 
1. On this page you'll see a `Project Name` and a `Project Id`.  You need to use the `Project Id` for the next step.
1. Leveraging the steps above make sure you can access the system and use the following URL: `curl -X POST http://<Item Ingest Host>/sync/<project id>`


## Monitoring
The item synchronization process writes information about its progres to the application's log file.  To monitor the item synchronization process as it runs, take the following steps, tail the log file on the Item Ingest Service pod in the Kubernetes cluster:

* Identify the Item Ingest Service pod:

	```
	$ kubectl get po | grep iis
	ap-imrt-iis-deployment-65c4cf5454-zrvs9     1/1       Running   0          3d

	```

* Tail the log file of the Item Ingest Service pod identified in the previous step:

	```
	$ kubectl logs -f ap-imrt-iis-deployment-65c4cf5454-zrvs9
	```

At this point, the pod's log file is being followed and details of the item synchronization process will be displayed.  The log entries that signify the item synchronization process has started will appear similar to what is shown below:

```
2018-05-09 08:31:03.254  INFO 92056 --- [cTaskExecutor-1] o.s.b.c.l.s.SimpleJobLauncher            : Job: [SimpleJob: [name=itemSynchronizationJob]] launched with the following parameters: [{}]
2018-05-09 08:31:03.265  INFO 92056 --- [cTaskExecutor-1] .ItemSynchronizationJobExecutionListener : Item Synchronization Process starting.  Job execution id: 15
2018-05-09 08:31:03.293  INFO 92056 --- [cTaskExecutor-1] o.s.b.c.j.SimpleStepHandler              : Executing step: [itemSynchronizationStep]
2018-05-09 08:31:03.312  INFO 92056 --- [cTaskExecutor-1] o.a.i.i.s.ItemSynchronizationServiceImpl : getting item bank ids from source control
2018-05-09 08:32:54.828  INFO 92056 --- [cTaskExecutor-1] o.a.i.i.s.ItemSynchronizationServiceImpl : retrieved 1811 item bank ids from source control in 111 seconds

... processing of each item bank id occurs ...

2018-05-09 08:32:54.845  INFO 92056 --- [cTaskExecutor-1] .ItemSynchronizationJobExecutionListener : Item Synchronization Process complete.  Job execution id: 15, exit status code: COMPLETED, exit message: Total item bank ids: 1811, number of items requiring project webhook: 10
2018-05-09 08:32:57.440  INFO 92056 --- [cTaskExecutor-1] o.s.b.c.l.s.SimpleJobLauncher            : Job: [SimpleJob: [name=itemSynchronizationJob]] completed with the following parameters: [{}] and the following status: [COMPLETED]
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
If the Item Synchronization Process encounters an exception, the job execution's status will be set to **FAILED** in the `batch_job_execution` table.  Furthermore, the exception message and stack trace will be recorded in the `exit_message` column of the `batch_job_execution` table.  To view the exception message and stack trace, execute the following SQL:

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
