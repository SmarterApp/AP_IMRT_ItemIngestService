# IMRT Item Ingest Service

The Item Ingest Service is responsible for ingesting the item data created by the content team. This project is part of the Item Metadata and Reporting Tool.

# Getting Started

This project requires certain pieces of software to run. Below is hte list and recommended order to install those pieces of software.  

* [Getting Started For Mac](documentation/getting_started_mac.md)

## Create database and users

Connect into PostgreSQL using the psql command line tool. You will need to initially connect using the 'postgres' user, password is whatever you set it to during the install. Once you connect, you will need to create a new user. You can set the password to whatever you like, it doesn't have to be imrt-admin:

<pre>
psql -U postgres
CREATE ROLE "imrt-admin" with LOGIN SUPERUSER CREATEDB CREATEROLE PASSWORD 'imrt-admin';
\q
</pre>

Now log back in the with the user you just created, and create the database:

<pre>
psql -U imrt-admin postgres
create database "imrt";
</pre>

From this point on, if you use psql, you will want to login with:
<pre>psql -U imrt-admin imrt</pre> to be connected to the imrt database

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

# Database connectivity info
flyway.user=<user>
flyway.password=<password>
flyway.url=<url> # Sample URL for local database named imrt: jdbc:postgresql://localhost:5432/imrt
```

## Create database tables

Clone the AP_IMRT_Schema project from https://github.com/SmarterApp/AP_IMRT_Schema. Run the gradle task "flywayMigrate" to create the database tables.


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

Finally, to disable findbugs, you must use the '-x' argument to gradle to prevent the 2 findbugs tasks from running, for example:

<pre>./gradlew build -x findBugsMain -x findBugsTest</pre>

## Docker Support
The project uses the [https://github.com/bmuschko/gradle-docker-plugin] to provide docker support.

To build the docker image locally, run
<pre>./gradlew dockerBuildImage</pre>

To run the docker image locally, run
<pre>
cd build/docker
docker-compose up
</pre>

As well as standing up the IMRT IIS service, docker-compose up will also bring up a Spring Cloud Configuration Service.
This service is configured to look in the directory $USER_HOME/sbac/imrt-config-repo for a git based configuration.
For example:

<pre>
mkdir -p ~/sbac/imrt-config-repo
cd ~/sbac/imrt-config-repo
git init
echo 'test.config="Test Config" > ap-imrt-iis.properties
git add .
git commit
</pre>

Once the application is running, you can hit the "testConfig" endpoint to verify the configuration service is running

<pre>
curl http://localhost:8080/testConfig
"Test Config"
</pre>
