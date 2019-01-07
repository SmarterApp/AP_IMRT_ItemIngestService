# Monitor IMRT Ingest Sync

During normal operation IMRT syncs single items in under a second after getting notified there are changes in Gitlab.  However, there are a couple cases where the number of changes being made to items in Gitlab is great enough to delay sync results.  

The two known instances where this occurs is:

* Syncing IMRT with Gitlab via the sync job
* TIMS Item Migrations

IMRT uses RabbitMQ for its internal messaging framework which allows for asynchronous processing of updates.  It also allows IMRT to quickly respond to Gitlab events.

## Monitoring Ingest Process

There are a couple ways to monitor the ingest sync system when it gets into a state where ingestion is slower than the amount of changes being made in Gitlab (mentioned in previous section).

### Monitor Sync Jobs

This document does not cover monitoring the job itself because this is already documented [here](items_are_not_syncing.md#check-the-database-tables).  The key is the start and end time.  Once the job is completed the job record will be updated with the status of "COMPLETED".

### Monitor Ingest

During a time where a lot of changes are being ingested one can monitor the RabbitMQ queues to get a rough idea of how quickly things are getting processed.  IMRT uses three queues which are described in the table below.

| Queue Name | Description |
| ---------- | ----------- |
| `imrt-update` | This is the ingest queue.  Each time an item is changed an update event message is placed, and the changes are ingested |
| `imrt-delete` | This is the discard queue.  When users discard an item or an administrator deletes an item from the itembank a delete event is placed on this queue for the item deleted. |
| `imrt-error` | This is a dead letter queue.  Any message that cannot be processed or errors are placed on this queue and logged. |


#### Steps to Track Ingest Processing

There are times when one may want to gather how ingest is proceeding from a time perspective or want the number of items still left to be ingested.  There isn't a 100% guaranteed way to know "how many items left to process" while users are using TIMS since it may create more updates.  However, the following steps can be used to gather a basic processing timeline when there are a lot of item updates to be ingested.

The steps below reference the preferred deployment leveraging Kubernetes.

1. Log onto the deployment machine and the user that has Kubenertes access for the process running.  
2. The IMRT system uses a rabbit cluster which will create three rabbit pods: `rabbitmq-0`, `rabbitmq-1`, `rabbitmq-2`.
3. Exec into each pod to find the `imrt-update` queue.  An example to get onto the `rabbitmq-2` pod is `kc exec -it rabbitmq-2 /bin/sh`.
4. Once in the pod run `rabbitmqctl list_queues --local` which will list all the queues on that particular pod.  In addition there will be the number of items left in the queue.  An example is provided below.

<pre>
# rabbitmqctl list_queues --local
Timeout: 60.0 seconds ...
Listing queues for vhost / ...
item-update	29139
item-delete	0
imrt-error	0
</pre>

Until the sync job or TIMS migrations complete the `item-update` queue will grow as item update events are added for ingest.  This is expected.  Once the sync job completes the number of items on the queue will decrease.  From here you can watch the number of items are removed from the queue over a time period to estimate the time remaining to clear the queue.


## Ingest Logging

There is quite a bit of logging available in IMRT Ingest. Those are better defined [here](logging.md).