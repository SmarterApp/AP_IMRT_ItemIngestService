# IMRT Item Ingest Service

The Item Ingest Service is reponsible for ingesting the item data created by the content team. This project is part of the Item Metadata and Reporting Tool.

# Getting Started

This project requires certain pieces of software to run. Below is hte list and recommended order to install those pieces of software.  

* [Getting Started For Mac](documentation/getting_started_mac.md)


## Configure global Gradle properties

Create `~/.gradle/gradle.properties` if it doesn't already exist
Edit `~/.gradle/gradle.properties`, paste these contents into the file:

```
# Your dockerhub user, password, and email
dockerHubUser=<dockerHubUser>
dockerHubPassword=<ask team members>
dockerHubEmail=<duckerHubEmail>

# Your git username and password
gitUsername=<your GitHub user>
gitPassword=<your GitHub pass>

# For releasing you'll need the following to point to the artifactory for the project.  The URL below is the Smarter Balanced Artifactory
artifactoryUrl=https://airdev.jfrog.io/airdev
artifactorySnapshotPublish=libs-snapshots-local
artifactoryReleasePublish=libs-releases-local
artifactoryUser=<artifactory User>
artifactoryPassword=<ask smarterbalanced>
```


