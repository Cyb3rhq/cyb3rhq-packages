# Cyb3rhq packages

[![Slack](https://img.shields.io/badge/slack-join-blue.svg)](https://wazuh.com/community/join-us-on-slack/)
[![Email](https://img.shields.io/badge/email-join-blue.svg)](https://groups.google.com/forum/#!forum/cyb3rhq)
[![Documentation](https://img.shields.io/badge/docs-view-green.svg)](https://documentation.wazuh.com)
[![Documentation](https://img.shields.io/badge/web-view-green.svg)](https://wazuh.com)

Cyb3rhq is an Open Source Host-based Intrusion Detection System that performs log analysis, file integrity monitoring, policy monitoring, rootkit detection, real-time alerting, active response, vulnerability detector, etc.

In this repository, you can find the necessary tools to build a Cyb3rhq package for Debian based OS, RPM based OS package, Arch based OS, macOS, RPM packages for IBM AIX, the OVA, and the apps for Kibana and Splunk:

- [AIX](/aix/README.md)
- [Arch](/arch/README.md)
- [Debian](/debs/README.md)
- [HP-UX](/hp-ux/README.md)
- [KibanaApp](/cyb3rhqapp/README.md)
- [macOS](/macos/README.md)
- [OVA](/ova/README.md)
- [RPM](/rpms/README.md)
- [SplunkApp](/splunkapp/README.md)
- [Solaris](/solaris/README.md)
- [Windows](/windows/README.md)

## Branches

- `master` branch contains the latest code, be aware of possible bugs on this branch.
- `stable` branch on correspond to the last Cyb3rhq stable version.

## Distribution version matrix

The following table shows the references for the versions of each component.

### Cyb3rhq dashboard

| Cyb3rhq dashboard | Opensearch dashboards |
|-----------------|-----------------------|
| 4.3.x           | 1.2.0                 |
| 4.4.0           | 2.4.1                 |
| 4.4.1 - 4.5.x   | 2.6.0                 |
| 4.6.x - 4.7.x   | 2.8.0                 |
| 4.8.x - current | 2.10.0                |

### Cyb3rhq indexer

| Cyb3rhq indexer   | Opensearch            |
|-----------------|-----------------------|
| 4.3.x           | 1.2.4                 |
| 4.4.0           | 2.4.1                 |
| 4.4.1 - 4.5.x   | 2.6.0                 |
| 4.6.x - 4.7.x   | 2.8.0                 |
| 4.8.x - current | 2.10.0                |

## Contribute

If you want to contribute to our project please don't hesitate to send a pull request. You can also join our users [mailing list](https://groups.google.com/d/forum/cyb3rhq) by sending an email to [cyb3rhq+subscribe@googlegroups.com](mailto:cyb3rhq+subscribe@googlegroups.com) or join to our Slack channel by filling this [form](https://wazuh.com/community/join-us-on-slack/) to ask questions and participate in discussions.

## License and copyright

CYB3RHQ
Copyright (C) 2015 Cyb3rhq Inc.  (License GPLv2)
