#!/usr/bin/env bash

kops export kubecfg --state @kubecfgState@ --name @kubecfgName@

kubectl set image deployment/@kubecfgDeployment@ ap-imrt-iis=@dockerTagBase@/ap-imrt-iis:@version@