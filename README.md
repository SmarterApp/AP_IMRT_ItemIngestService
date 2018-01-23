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

## Building with Gradle
<pre>./gradlew build</pre>
The standard gradle "build" target will build the source code, run findbugs, and run all unit and integration tests.
If findbugs discovers any issues, the build will fail.

<pre>./gradlew jacocoTestReport</pre>
The JaCoCo plugin is enabled, so if you want to generate code coverage reports, just run the standard "jacocoTestReport" gradle task


Test, findbugs, and code coverage reports will be generated in the default location:
<pre>.projectDir/build/reports</pre>

During development, you may wish to run just unit tests, rather than the full suite of unit and integration tests. There is a gradle task "unitTest" configured for that. 
To support this, all integration tests must follow the naming convention XxxIntegrationTest.java
<pre>./gradlew unitTest</pre>
