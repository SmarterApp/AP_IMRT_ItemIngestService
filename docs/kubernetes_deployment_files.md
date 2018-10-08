# IMRT Kubernetes Deployment Files

[Go Back](../README.md)

IMRT applications leverage [Kubernetes](https://kubernetes.io/) for application deployments. These files will contain sensitive information for your deployments so we recommend them being stored in a private repository or in an internal system with controlled access.

These files are located in `deployment/kubernetes` directory within this project.  Files have the text (or something similar) "set during deployment" for anything that should be set by the deployer.

Any file that is not listed in this document does not require additional configuration by the deployer and can be used *as is*.

## How to read this document
All files leverage the [YAML](https://en.wikipedia.org/wiki/YAML) markup language.  Each section has a table describing the properties and description to help the deployer configure the system. All properties listed must be set. 

Values in these files need to be saved as **plain text**.

## Confgiuration Service
This configures the Spring Cloud Config service that the applications use to get configuration information.

**File Name:** configuration-service.yml

The properties are in the `env` section in the example file.

| Property Name | Description | Example Value |
| ------- | ---- | ----|
| `CONFIG_SERVICE_REPO` | Github/Gitlab repository for Spring Cloud config files | `https://gitlab.com/smarterbalanced/something.git`
| `GIT_USER` | The Github/Gitlab user for the repo | | 
| `GIT_PASSWORD` | The password for the Git user | |
| `ENCRYPT_KEY` | The encryption key set for Spring encryption | The secret key when you encrypt application values. | 

## Rabbit Cluster
This configures Rabbitmq which is used for internal application messaging.

**File Name:** rabbit-cluster.yml

The properties are in the `env` section in the example file.

| Property Name | Description | Example Value |
| ------- | ---- | ----|
| `RABBITMQ_ERLANG_COOKIE` | A random text string. More information [here](https://www.rabbitmq.com/clustering.html#erlang-cookie) | someCoolValue |
| `RABBITMQ_DEFAULT_USER` | The username to connect to rabbit | | 
| `RABBITMQ_DEFAULT_PASS` | The username's password | |

## Item Ingest Service Deployment
This configures IMRT's Item Ingest Service.

**File Name:** iis.yml

The properties are in the `env` section in the example file.

| Property Name | Description | Example Value |
| ------- | ---- | ----|
| `SPRING_CLOUD_CONFIG_LABEL` | The branch containing the Spring Cloud configuration files. | `master` |
| `GRAYLOG_HOST` | The graylog host to send logs from the application | |

## Item Search Service Deployment
This configures IMRT's Item Ingest Service.

**File Name:** iis.yml

The properties are in the `env` section in the example file.

| Property Name | Description | Example Value |
| ------- | ---- | ----|
| `SPRING_CLOUD_CONFIG_LABEL` | The branch containing the Spring Cloud configuration files. | `master` |
| `GRAYLOG_HOST` | The graylog host to send logs from the application | |

## Load Balancer
The load balancer handles incoming requests and routes it to the proper service to handle the request.

**File Name:** load-balancer.yml

The properties are in the `annotations` section in the example file.

| Property Name | Description | Example Value |
| ------- | ---- | ----|
| `service.beta.kubernetes.io/aws-load-balancer-ssl-cert` | The ARN for the ssl certificate |  |

## IMRT Ingress
The ingress manages external access ot the services in the kluster.  For more information please refer to the [documentation](https://kubernetes.io/docs/concepts/services-networking/ingress/).

**File Name:** load-balancer.yml

The properties are in the `spec.rules` section in the example file.  There are two `host` properties that need to be set.  The `host` for `ap-imrt-iis-service` needs to be set to whatever CNAME the deployer has configured for the ingest service.  The `host` for `ap-imrt-iss-service` needs to be set to whatever CNAME the deployer has configured for the search service.
