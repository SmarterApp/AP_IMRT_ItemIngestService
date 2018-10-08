# Release Notes

[Go Back](../README.md)

## Prior to Upgrade

The steps below list out the recommended steps to take prior to upgrading a system.  Each release notes will list how to upgrade from a previous version of the system. 

### Verify the state of the current system
Prior to upgrade one should check to ensure all the pods are up and running.  In addition one should run a general search against the Item Search Service (ISS) to ensure the state of the system prior to upgrade.

### Backup the database
Do a full backup of the database.  Releases may run schema migrations which will alter the tables and data in the system.  To ensure one can roll back to a previous release it is important to have a backup of the database prior to the migrations.

### Backup Configuration Files
If you are using source control to manage deployment and configuration files then you can ignore this section as one can leverage source control to go to a previous version.

If you're not using source control one will want to make sure to backup the previous deployment/configuration files to a location so the system can be reconstructed using previous deployments.

## How to handle if one can't rollback?
**Note** - One should always back up the database prior to upgrade so one can always go back to a version.. 

Depending on the changes it may not be possible to rollback a deployment.  In that case you may need to rebuild the system.  Please refer to the [Deployment Checklist](Deployment.AWS.md) on how to deploy a new system.

If data is lost or the backup wasn't done all is not lost.  The IMRT ingest service can ingest all the items from scratch by leveraging the [item sync](item-sync.md) process.  This can be manually called and will ingest all the items in the configured itembank.

## Release Notes

### 0.1.0
Since this is the initial release for IMRT there are no upgrade notes. Deployers should use the [Deployment Checklist](Deployment.AWS.md) to deploy the system.

**Application Versions**

| Release Location | Version | Notes |
| ----- | ----- | ---- |
| [0.1.0 Github Release](https://github.com/SmarterApp/AP_IMRT_Schema/releases/tag/0.1.0) | 0.1.0 | The attached `AP_IMRT_Schema.jar` should be used to configure the schema |
| [IIS Docker](https://hub.docker.com/r/smarterbalanced/ap-imrt-iis/tags/)| 0.1.28 | This docker version should be used in deployment files for ingest service and sync cron| 
| [ISS Docker](https://hub.docker.com/r/smarterbalanced/ap-imrt-iss/tags/)| 0.1.21 | This docker version should be used in deployment files for search service| 

### 0.1.1
New deployments should leverage the [Deployment Checklist](Deployment.AWS.md) to deploy the system using the versions below.  Existing systems please use the upgrade notes within this section.

**Application Versions**

| Release Location | Version | Notes |
| ----- | ----- | ---- |
| [0.1.2 Release](https://github.com/SmarterApp/AP_IMRT_Schema/releases/tag/0.1.2) | 0.1.2 | The published release has the schema jar that can be downloaded and run to verify the schema is at the correct migration version. |
| [0.1.32 Image](https://hub.docker.com/r/smarterbalanced/ap-imrt-iis/tags/)| 0.1.32 | This docker version should be used in deployment files for ingest service and sync cron| 
| [0.1.31 Image](https://hub.docker.com/r/smarterbalanced/ap-imrt-iss/tags/) | 0.1.31 | This docker version should be used in deployment files for search service| 

#### Update Notes
These notes should be used if upgrading IMRT from 0.1.0 to 0.1.1.  As mentioned above one should back up the database before proceeding.

1. Run the IMRT Schema Jar using the jar attached to the schema release in the table above.
	2. The schema migration should be moved to 13.  You can check this looking at the schema migration table. 
2. Update your IIS (iis.yml in deployment files) deployment's release version to the docker version used above.  
3. Update your ISS (iss.yml in the deployment files) deployment's release version to the docker version used above.
4. Apply both the IIS and ISS with `kubectl apply -f <filename>`
5. Once both systems have been updated verify ingest works with syncing the system.
6. Verify search by hitting the https endpoint for ISS general search.

### 0.1.2
This contains the functionality for the phase 2 of IMRT.

**Application Versions**

| Release Location | Version | Notes |
| ----- | ----- | ---- |
| [0.1.5 Release](https://github.com/SmarterApp/AP_IMRT_Schema/releases/tag/0.1.5) | 0.1.5 | The published release has the schema jar that can be downloaded and run to verify the schema is at the correct migration version. |
| [0.1.46 Image](https://hub.docker.com/r/smarterbalanced/ap-imrt-iis/tags/)| 0.1.46 | This docker version should be used in deployment files for ingest service and sync cron| 
| [0.1.48 Image](https://hub.docker.com/r/smarterbalanced/ap-imrt-iss/tags/) | 0.1.48 | This docker version should be used in deployment files for search service| 

#### Update Notes
These notes should be used if upgrading IMRT from 0.1.1 to 0.1.2.  As mentioned above one should back up the database before proceeding.

1. Run the IMRT Schema Jar using the jar attached to the schema release in the table above.
	2. The schema migration should be moved to 20.  You can check this looking at the schema migration table. 
2. Update your IIS (iis.yml in deployment files) deployment's release version to the docker version used above.  
3. Update your ISS (iss.yml in the deployment files) deployment's release version to the docker version used above.
4. Update the sync-cron.yml file to the proper IIS version (0.1.46)
4. Apply both the IIS and ISS with `kubectl apply -f <filename>`
5. Once both systems have been updated verify ingest works with syncing the system.
6. Verify search by hitting the https endpoint for ISS general search.

#### Configure GELF logging
This realease has GELF logging within the application.  This uses an appender and relies on values set in the environment variables.

In each of the iis and iss deployment files you will need to add the following to the environment variables section (`env`):
<pre>
        - name: GRAYLOG\_HOST
          value: "<graylog host>"
        - name: GRAYLOG\_PORT
          value: "<graylog port>"
</pre>

#### Disabling GELF daemonset
If a previous deployment used a gelf daemonset you will need to disable the existing daemonset because having both will produce double logs.

Run the following steps:

1. `kubectl get daemonset -n kube-system`
2. `kubectl delete daemonset [name of daemonset from previous command] -n kube-system`