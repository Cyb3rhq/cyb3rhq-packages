#!/bin/sh
# uninstall script for cyb3rhq-agent
# Cyb3rhq, Inc 2015

install_path=$1
control_binary=$2

## Stop and remove application
${install_path}/bin/${control_binary} stop
rm -r /var/ossec*

# remove launchdaemons
rm -f /etc/init.d/cyb3rhq-agent

## Remove User and Groups
userdel cyb3rhq
groupdel cyb3rhq

exit 0
