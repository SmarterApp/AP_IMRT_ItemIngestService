# IMRT Configuration Files

[Go Back](../README.md)

IMRT applications leverage [Spring Cloud Config](https://cloud.spring.io/spring-cloud-config/) for application configurations.  This can be used to set configurable properties for the application, and those configuration properties are read during startup.

These include but are not limited to:

* database connection information
* OpenAM authentication
* Item Bank configuration

These files should be hosted in a Github or Gitlab type server which can be accessed by these applications.  Our recommendation is to host them in a private repository, as directed in the [deployment checklist](Deployment.AWS.md). In addition to being secured in a private repository, sensitive information can be encrypted via the [Spring CLI](https://cloud.spring.io/spring-cloud-cli/).

These files are located in `deployment/config` directory within this project.  Files have the text (or something similar) "set during deployment" for anything that should be set by the deployer.

## How to read this document
All files leverage the [YAML](https://en.wikipedia.org/wiki/YAML) markup language.  Each section has a table describing the properties and description to help the deployer configure the system. All properties listed must be set. 

The `.` character denotes the level of property. For example, the property `spring.datasource.url` can be represented like:

`spring.datasource.url="db url"`

**OR**
<pre>
spring:
  datasource:
    url: "db url"
</pre>

The example files use the second style.

## IMRT Item Search Service
The configuration for the item search service is `ap-imrt-iss.yml` within the `deployment/config` directory.  This file is used to configure the search application that allows item search.

| Property Name | Description | Example Value |
| ------- | ---- | ----|
| spring.datasource.url | The database endpoint | `imrt-somthing-us-east-2b.xxx.us-east-2.rds.amazonaws.com` |
| spring.datasource.username | application's database user | `imrt_search` |
| spring.datasource.password | application's database user's password | |
| openam.checkTokenEndpointUrl | The installation's OpenAM server token URL | `https://<openam url>/auth/oauth2/tokeninfo` |

## IMRT Item Ingest Service
The configuration for the item ingest service is `ap-imrt-iis.yml` within the `deployment/config` directory.  This file is used to configure the ingest application that allows item ingest into IMRT.

| Property Name | Description | Example Value |
| ------- | ---- | ----|
| spring.datasource.url | The database endpoint | `imrt-somthing-us-east-2b.xxx.us-east-2.rds.amazonaws.com` |
| spring.datasource.username | application's database user | `imrt_search` |
| spring.datasource.password | application's database user's password | spring.rabbitmq.username | rabbitmq username setup during deployment | |
| spring.rabbitmq.password | rabbitmq username's password setup during deployment | 
| itembank.host | the gitlab url for the itembank | `https://gitlab.smarterbalanced.org/` |
| itembank.accessToken | a gitlab user's access token that has the ability read all projects | |
| itembank.group | the gitlab project group to ingest | `iat-uat` |
| itembank.webhookUrl | The url to the installed IIS server | `https://iis.smarterbalanced.org/webhook` |

