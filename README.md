# IMRT Item Ingest Service

The Item Ingest Service is reponsible for ingesting the item data created by the content team. This project is part of the Item Metadata and Reporting Tool.

# Getting Started

This project requires certain pieces of software to run. Below is hte list and recommended order to install those pieces of software.  

## Install Homebrew 
[Homebrew Site](https://brew.sh/)

*Install*

1. Open a terminal
2. `/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)`

*Verify*

1. Open a terminal
1. brew -v
1. The version should be displayed

## Install Java 8 SE Development Kit 

1. Download installer from [here](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)
1. Run the installer

*Verify*

1. Open a terminal
1. java -version
1. The version should be displayed

## Install Gradle
[Gradle](https://gradle.org)

*Install*

1. Open a terminal
1. brew install gradle

*Verify*

1. Open a terminal
1. gradle -v
1. The version should be displayed

###Configure global Gradle properties

Create "~/.gradle/gradle.properties" if it doesn't already exist
Edit "~/.gradle/gradle.properties", paste these contents into the file:

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


