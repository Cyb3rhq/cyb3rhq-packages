#!/bin/sh
# preremove script for cyb3rhq-agent
# Cyb3rhq, Inc 2015

control_binary="cyb3rhq-control"

if [ ! -f /var/ossec/bin/${control_binary} ]; then
  control_binary="ossec-control"
fi

/var/ossec/bin/${control_binary} stop
