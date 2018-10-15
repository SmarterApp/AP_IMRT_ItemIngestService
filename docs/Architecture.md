# IMRT Architecture

[Go Back](../README.md)

This page describes the architecture/design of the various components/subsystems that comprise the IMRT application:

### [Database Schema Document](https://github.com/SmarterApp/AP_IMRT_Schema/blob/develop/docs/imrt_schema_document.md)
This document describes the schema.  This will take you to the `AP_IMRT_Schema` project which has all the DB information for the IMRT project

### [Item Synchronization Process](item-sync.md)
The item synchronization process is an endpoint in the system that can be used to sync IMRT manually with the itembank.

### [Item Data Migration Process](item-migration.md)
The item data migration process is an endpoint in the system that can be used to update new fields and/or tables introduced into the IMRT database with data from the itembank.
