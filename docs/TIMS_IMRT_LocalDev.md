# TIMS & IMRT Local Development
Currently IMRT relies on Gitlab for item update events.  This can make local development difficult because Gitlab cannot make calls to your local machine without a separate service.  This document covers two ways to get data into IMRT from TIMS during local development.

## Manual Updates
This is the easiest way to get TIMS local sync.  This section will cover two ways to get manual updates from TIMS.  If you need to get lots of updates please look at the ngrok section.

### Sync all items
This covers how to sync the entire group to your local system

1. The gitlab group uses the environment variables you set during IMRT setup.
2. Start the IMRT Ingest Service with `./gw bootRunLocal`.
3. From the command line run `curl -X POST http://localhost:9081/sync`
4. This will go through ever item in Gitlab and sync it to IMRT

You may need to abandon a previous job if you killed the server before a job was completed.  Those notes are in the next "Abandon a job" section".

### Sync a single item
If you have a lot of items in your group syncing all items can take a while especially if you only care about a single item.  The following steps are very similar to syncing all the items.

1. The gitlab group uses the environment variables you set during IMRT setup.
2. Start the IMRT Ingest Service with `./gw bootRunLocal`.
3. Get the Gitlab internal project id from gitlab.  You can find this on the settings tab in Gitlab in the "Project ID" field.  Note that this number is different than the item id.
3. From the command line run `curl -X POST http://localhost:9081/sync/<project id>`
4. Replace the project id in the above with the one you retrieved in step 3.
5. This will go through ever item in Gitlab and sync it to IMRT

### Abandon a job
IMRT uses Spring batch to handle the execution of the sync.  The framework starts and tracks jobs updating when the job completes.  When one kills the server during a job Spring batch cannot figure out the state of the job after restart.  When you try to start the job you will receive an error from the server giving you the job instance id and saying the job is running.

1. Get the job instance id from the error message.
2. Run `curl -X PUT http://localhost:9081/abandon/<jobInstanceId>`
3. In the previous step you'll want to replace the `<jobInstanceId>` with the one in the error message in the first step.


## Use NGROK
Ngrok can be used to allow Itembank gitlab call your local server.  This is helpful if you're making a bunch of changes are want to see the exact message being sent by Gitlab.

1. download [ngrok](https://ngrok.com/download)
2. start it up: `ngrok http 9081`
3. Observe the goofy url it gives you (e.g. `http://25d81d97.ngrok.io`)
4. update IIS’s `GITLAB_WEBHOOK_URL` to the url in step 3 (e.g. `http://25d81d97.ngrok.io/webHook`)
in GitLab, navigate to **Admin Area** -> **System Hooks** (link for SBAC gitlab: https://gitlab-dev.smarterbalanced.org/admin/hooks)
5. Create a Sytem Hook for the `ngrok` url (e.g. `http://25d81d97.ngrok.io/systemHook`)
6. Use the gitlab access token (e.g. `UbS69_PYvCgsjyxBFcgL`, can be found https://confluence.fairwaytech.com/pages/viewpage.action?pageId=155451407
7. Click **Add System Hook**
8. Start up IIS in IntelliJ or with `./gw bootRunLocal`

At this point, when you create a new item you should see IIS pick up the message.

