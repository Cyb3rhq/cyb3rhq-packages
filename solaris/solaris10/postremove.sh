#!/bin/sh
# postremove script for cyb3rhq-agent
# Cyb3rhq, Inc 2015

if getent passwd cyb3rhq > /dev/null 2>&1; then
  userdel cyb3rhq
fi

if getent group cyb3rhq > /dev/null 2>&1; then
  groupdel cyb3rhq
fi
