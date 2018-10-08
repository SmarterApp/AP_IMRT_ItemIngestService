# Item Data Migration Process

[Go Back](Architecture.md)

## Overview
The Item Data Migration Process is responsible for ensuring new fields and/or tables added IMRT database (which the [Item Search Service](https://github.com/SmarterApp/AP_IMRT_ItemSearchService) relies on) are populated with data from the item stored in source control (e.g. GitLab).  The Item Data Migration Process iterates over every item record in the IMRT database and fetches the most recent revision for each one.  When the Item Data Migration Process is complete, new fields and/or tables added to the IMRT database will accurately reflect the items stored in source control.

## Architecture/Implementation
The Item Data Migration Process is a [Spring Batch](https://projects.spring.io/spring-batch/) job with a single step.  The details of the operations performed by the step are described in the **Workflow** section below.

### Workflow
The Item Data Migration process is initiated by an `HTTP POST` request to the `migrate` endpoint of the Item Ingest Service.  The `migrate` endpoint does not accept any arguments.  After the `POST` to `migrate` is received, the following steps occur:

1. The `ItemIngestJobController` will start a new instance of the Item Data Migration Process job
2. The Item Data Migration Process job is started asynchronously by a Spring Batch `JobLauncher`
3. If the job started successfully, the `ItemIngestJobController ` will respond with a `200`.  The response payload will contain the job execution id and its status.  An example response payload is shown below:

	```json
	{"jobExecutionId":6,"name":"itemMigrationJob","status":"STARTING"}
	```
	 
4. The `ItemIngestJobController#migrate` method is called, which does the following for all of the records in the `item_git` table:
    1. Get a subset of records (i.e. a "page") from the `item_git` table
    2. For each `item_git` record in the page, put a "migrate item" message on the queue

Once the messages have been put on the RabbitMQ queue, the Item Data Migration Process is complete.  The Item Ingest Process will read each message, evaluate it and perform the appropriate action:

**Migrate Item:** This message will use the GitLab API library (implemented in the [AP\_IMRT\_ItemIngestService](https://github.com/SmarterApp/AP_IMRT_ItemIngestService/blob/develop/src/main/java/org/opentestsystem/ap/imrt/iis/client/GitlabClientImpl.java)) to:

1. Get the current version of the `item.json` for the item
2. Save that revision to the IMRT database, thus populating all the newly added fields and/or tables with current values from the item

Shown below is a sequence diagram of the steps described above:

![item data migration sequence diagram](../assets/images/irmt-item-migration-job.png)

***NOTE:*** The message listener that intercepts the messages put on the queue by the Item Data Migration Process has been omitted for clarity.

### Database
Aside from the [Spring Batch metadata tables](https://docs.spring.io/spring-batch/trunk/reference/html/metaDataSchema.html), the Item Data Migration Process does not rely on any special database objects.  The Spring Batch metadata tables are used to track the Item Data Migration Process's execution, progress, status, etc.

The Item 

### Restrictions
There can only be one instance of the Item Data Migration Process job running at one time.

## Configuration
The Item Data Migration Process is part of the [AP\_IMRT\_ItemIngestService](https://github.com/SmarterApp/AP_IMRT_ItemIngestService), thus shares its configuration properties.  Refer to the AP\_IMRT\_ItemIngestService `README.md` for details on configuration options.

As previously stated, the Item Data Migration Process relies on Spring Batch.  There are two settings specific to Spring Batch that need to be configured:

* Prevent Spring Batch from starting the Item Data Migration Process whenever the Item Ingest Service starts up
* Prevent Spring Batch from trying to create its database schema on startup (these tables are created as part of the [AP\_IMRT\_Schema project](https://github.com/SmarterApp/AP_IMRT_Schema))

These configuration settings are detailed below:

```yaml
spring:
  batch:
    job:
      enabled: false # Prevent Spring from starting jobs on startup.
    initialize-schema: "never" # Prevent Spring from creating the spring batch schema on startup.
  # other spring-related settings here...
```

The Spring Batch configuration settings described above will typically be included in the `yml` file served up by IMRT's Spring Cloud Configuration service.  When working in a local development environment (e.g. running the Item Ingest Service in IntelliJ), the settings can be included in an `application.yml` file.