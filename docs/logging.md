# IMRT Logging

IMRT logging can be configured prior to startup in the Spring configuration YAML file.  In the YAML file there should be a logging configuration like this:

<pre>
logging:
  level:
    org.opentestsystem: WARN
    org.opentestsystem.ap.imrt: DEBUG
    org.gitlab4j: INFO
</pre>

The `org.opentestsystem` is the package name for all SB code.  The different settings for this follow standard Log4j [log levels](https://logging.apache.org/log4j/2.x/log4j-api/apidocs/org/apache/logging/log4j/Level.html).  However, IMRT specifically uses DEBUG, INFO, WARN, and ERROR levels.

## IMRT Log Prefixes

In addition to the log levels IMRT prefixes its logs to make it easier to find logs in a log aggregator like Graylog.

| Log Prefix | Log Level | Description |
| ---------- | --------- | ---------- |
| IMRT_DEBUG | DEBUG | IMRT debug messages provide a lot of detail but there is a lot of messaging that will occur. |
| IMRT_INFO | INFO | These are informational messages that provide good data points.  For example, INFO level will be used when syncing an item. |
| IMRT_WARN | WARN | These are messages that indicate there was an issue but it was an expected issue. |
| IMRT_ERROR | ERROR | These are any errors that cannot be handled or are unexpected |

## IMRT Event Prefixes	

IMRT logs item related events as it ingests and monitors items.  These are all logged at INFO level but can be used to find specific item events.

| Prefix | Description |
| ------ | ----------- |
| ITEM_MONITORED | This means that IMRT is aware of the item and is monitoring changes.  This is the first step in the process of ingesting an item. |
| ITEM_CREATED | This means the item is created within the IMRT system. |
| ITEM_UPDATED | This is similar to created and means the item has been updated with the latest data |
| ITEM_DELETED | This means the item has been deleted from the itembank and deleted from IMRT |

## IMRT Sync Job Logging

IMRT logs additional information when running the sync job.  All those messages are at IMRT_INFO level with the prefix `Sync-Item-Job:`

The example log below is tracking how long it takes to get a list of items from Gitlab.

```
INFO 1 --- [cTaskExecutor-1] a.i.i.s.i.ItemSynchronizationServiceImpl : IMRT_INFO: Sync-Item-Job: Get page 364 from gitlab in 868 ms
```
