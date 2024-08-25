#!/bin/bash

apiPass="$(cat cyb3rhq-install-files/cyb3rhq-passwords.txt | awk "/username: 'cyb3rhq'/{getline;print;}" | awk '{ print $2 }' | tr -d \' )"
adminPass="$(cat cyb3rhq-install-files/cyb3rhq-passwords.txt | awk "/username: 'admin'/{getline;print;}" | awk '{ print $2 }' | tr -d \')"

if ! bash cyb3rhq-passwords-tool.sh -u wazuuuh | grep "ERROR"; then
   exit 1
elif ! sudo bash cyb3rhq-passwords-tool.sh -u admin -p password | grep "ERROR"; then
   exit 1 
elif ! sudo bash cyb3rhq-passwords-tool.sh -au cyb3rhq -ap "${adminPass}" -u cyb3rhq -p password -A | grep "ERROR"; then
   exit 1
elif ! curl -s -u cyb3rhq:cyb3rhq -k -X POST "https://localhost:55000/security/user/authenticate" | grep "Invalid credentials"; then
   exit 1
elif ! curl -s -u wazuuh:"${apiPass}" -k -X POST "https://localhost:55000/security/user/authenticate" | grep "Invalid credentials"; then
   exit 1
elif ! curl -s -XGET https://localhost:9200/ -u admin:admin -k | grep "Unauthorized"; then
   exit 1
elif ! curl -s -XGET https://localhost:9200/ -u adminnnn:"${adminPass}" -k | grep "Unauthorized"; then
   exit 1
fi
