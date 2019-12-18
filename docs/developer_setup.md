# Developer Notes

## Getting Started

This project requires certain pieces of software to run. Below is hte list and recommended order to install those pieces of software.  

* [Getting Started For Mac](getting_started_mac.md)

## Other helpful notes

* [TIMS & IMRT Integration local dev](TIMS_IMRT_LocalDev.md)

## Create database and users

Two databases are required for IMRT

* test - test db used in integration tests
* imrt - main application db

Setting up the databases is documented in the [IMRT_Schema](https://github.com/SmarterApp/AP_IMRT_Schema) project.


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

# Optional - Database connectivity info
flyway.user=<user>
flyway.password=<password>
flyway.url=<url> # Sample URL for local database named imrt: jdbc:postgresql://localhost:5432/imrt
```

## Building with Gradle

The database tests that are part of the build require access to the test database on your local machine. 
Before you can run them you need to export the following environment variables:
<pre>
export SPRING_DATASOURCE_USERNAME=test
export SPRING_DATASOURCE_PASSWORD=<password>
</pre> 

You can then run:
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

## GitLab

IIS interacts with Gitlab, and on startup attempts to communicate with the configured Gitlab server. 
You can use a "real" Gitlab server on the internet, but unless your firewall allows it, the server 
will not be able to send you systemHook and webHook notifications. To work around this it is possible
 to run a local Gitlab server, though it requires a significant CPU and memory resources. 
 You can install and configure one using docker following the directions here: https://docs.gitlab.com/omnibus/docker/README.html

Before running IIS locally, you need to set the following environment variables, either in your terminal or in Intellij:

<pre>
export GITLAB_HOST=http://<host>
export GITLAB_GROUP=
export GITLAB_ACCESS_TOKEN=<create an access token on your Gitlab server>
export GITLAB_WEBHOOK_URL=
The webhook URL is the URL that is registered with the server for callbacks to IIS when a new project is created.
If you are using a remote GitLab server and don't have access through your firewall for webhooks you can just leave it blank
</pre>


## Docker Support
The project uses the [https://github.com/bmuschko/gradle-docker-plugin] to provide docker support.

To build the docker image locally, run
<pre>./gradlew dockerBuildImage</pre>

To run the docker image locally, you will first need to define the GITLAB environment variables as described above.
These will be taken from the local environment and passed through to the container from within docker-compose.
In additon, you will need to set environment variables containing the username and password for your database:
<pre>
export SPRING_DATASOURCE_USERNAME=imrt_ingest
export SPRING_DATASOURCE_PASSWORD=<password>
</pre>

Once all the variables are set, run:
<pre>
cd build/docker
docker-compose up
</pre>

As well as standing up the IMRT IIS service, docker-compose up will also bring up RabbitMQ and a Spring Cloud Configuration Service.
The configuration service is configured to look in the directory $USER_HOME/sbac/imrt-config-repo for a git based configuration.
For example:

<pre>
mkdir -p ~/sbac/
git clone https://gitlab.com/fairwaytech/imrt-config-repo.git
</pre>

## Command Line Execution

The easiest way to test changes to IIS via the command line is to first use docker-compose to bring up all the containers.
Now use docker stop to kill off IIS. Make sure you have all the required environment variables as described above,
and then run 
<pre>./gradlew bootRun</pre>

## Running within an IDE

To execute unit tests within an IDE, make sure that an appropriate SPRING_DATASOURCE_USERNAME and SPRING_DATASOURCE_PASSWORD are configured.

To execute IIS from with an IDE, make sure both the datasource and gitlab environment variables are set.






 