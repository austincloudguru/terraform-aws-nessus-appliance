%{ if license == "preauth" }{
    "name": "${name}",
    "key": "${key}",
    %{ if proxy != "" }"proxy": ${proxy},%{ endif }
    %{ if proxy_port != "" }"proxy": ${proxy_port},%{ endif }
    "iam_role": "${role}"
}%{ endif }%{ if license == "byol" }#!/bin/bash
yum update -y
service nessusd stop
/opt/nessus/sbin/nessuscli managed link --key=${key} --cloud
service nessusd start
%{ endif }%{ if license == "byol-sc" }#!/bin/bash
yum update -y
yum install -y expect jq

cat << EOF > /tmp/nessuscli_adduser.expect 
#!/usr/bin/expect -f
set timeout -1

set nessuscli_path [lindex \$argv 0];
set username [lindex \$argv 1];
set password [lindex \$argv 2];
set is_admin [lindex \$argv 3];

# update with path to nessuscli
spawn \$nessuscli_path adduser \$username

expect "Login password:"
send -- "\$password\n"

expect "(again)"
send -- "\$password\n"

expect "Do you want this user to be a Nessus"
send -- "\$is_admin\n" 


expect "the user can have an empty rules set"
send -- "\n"


expect "Is that ok"
send -- "y\n"

expect "User added"
EOF

chmod 700 /tmp/nessuscli_adduser.expect

${nessus_credentials}


service nessusd stop
/opt/nessus/sbin/nessuscli fetch --security-center
/tmp/nessuscli_adduser.expect /opt/nessus/sbin/nessuscli $NESSUS_USER $NESSUS_PASSWORD y
service nessusd start
%{ endif }
