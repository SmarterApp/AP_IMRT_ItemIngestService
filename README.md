# Item Ingest Service (IMRT)

This project handles ingesting data from the item bank into the IMRT search database.  It handles capturing and deriving data which can be searched on within the [Item Authoring Tool](https://github.com/SmarterApp/AP_ItemAuthoringTool).  This readme contains the necessary information to develop, deploy, and mantain the application.

## Tech Stack

At a high level the project uses the following technologies.

* Java 8
* SpringBoot
* Postgres
* RabbitMq
* Docker
* Kubernetes (deployments)

## Documentation

1. [Main README (this file)](README.md)
2. [Architecture](docs/Architecture.md)
3. [Developer Notes](docs/developer_setup.md)
4. [Item Ingest Kubernetes Deployment Files](docs/kubernetes_deployment_files.md)
5. [Item Ingest Application Configuration files](docs/config_files.md)
6. [Release Notes](docs/release_notes.md)
7. [Logging](docs/logging.md)

### Common Tasks
* [Delete an Item](docs/delete-item.md)
* [Running and Monitoring the Item Synchronization Process](docs/exec-item-sync.md)
* [Running and Monitoring the Item Data Migration Process](docs/exec-item-migration.md)

### Troubleshooting
* [Items aren't syncing](docs/items-not-syncing.md)
* [Sync job has started but not ended](docs/job_start_no_end.md)


## License
IMRT is owned by Smarter Balanced and covered by the Educational Community License:

```text
Copyright 2018 Smarter Balanced Licensed under the
Educational Community License, Version 2.0 (the "License"); you may
not use this file except in compliance with the License. You may
obtain a copy of the License at http://www.osedu.org/licenses/ECL-2.0.

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an "AS IS"
BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
or implied. See the License for the specific language governing
permissions and limitations under the License.
```