%{ if license == "preauth" }{
    "name": "${name}",
    "key": "${key}",
    %{ if proxy != "" }"proxy": ${proxy},%{ endif }
    %{ if proxy_port != "" }"proxy": ${proxy_port},%{ endif }
    "iam_role": "${role}"
}
%{ else }#!/bin/bash
 yum update -y
 service nessusd stop
 /opt/nessus/sbin/nessuscli managed link --key=${key} --cloud
 service nessusd start
%{ endif }
