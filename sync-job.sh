#!/bin/sh
echo Executing Item Sync Job

# Invoke the endpoint to kick off the sync job. The URL is the k8s service name for iis
# TODO capture the response (jobId) to use for monitoring once that functionality is available
curl -i "http://ap-imrt-iis-service/systemHook"

# TODO poll for completion once that functionality is available