#!/bin/sh
# uninstall script for cyb3rhq-agent
# Cyb3rhq, Inc 2015

control_binary="cyb3rhq-control"

if [ ! -f /var/ossec/bin/${control_binary} ]; then
  control_binary="ossec-control"
fi

## Stop and remove application
/var/ossec/bin/${control_binary} stop
rm -rf /var/ossec/

## stop and unload dispatcher
#/bin/launchctl unload /Library/LaunchDaemons/com.cyb3rhq.agent.plist

# remove launchdaemons
rm -f /etc/init.d/cyb3rhq-agent
rm -rf /etc/rc2.d/S97cyb3rhq-agent
rm -rf /etc/rc3.d/S97cyb3rhq-agent

## Remove User and Groups
userdel cyb3rhq 2> /dev/null
groupdel cyb3rhq 2> /dev/null

exit 0
