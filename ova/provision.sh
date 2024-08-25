#!/bin/bash

PACKAGES_REPOSITORY=$1
DEBUG=$2

RESOURCES_PATH="/tmp/unattended_installer"
BUILDER="builder.sh"
INSTALLER="cyb3rhq-install.sh"
SYSTEM_USER="cyb3rhq-user"
HOSTNAME="cyb3rhq-server"
INDEXES=("cyb3rhq-alerts-*" "cyb3rhq-archives-*" "cyb3rhq-states-vulnerabilities-*" "cyb3rhq-statistics-*" "cyb3rhq-monitoring-*")

CURRENT_PATH="$( cd $(dirname $0) ; pwd -P )"
ASSETS_PATH="${CURRENT_PATH}/assets"
CUSTOM_PATH="${ASSETS_PATH}/custom"
BUILDER_ARGS="-i"
INSTALL_ARGS="-a --install-dependencies"

if [[ "${PACKAGES_REPOSITORY}" == "dev" ]]; then
  BUILDER_ARGS+=" -d"
elif [[ "${PACKAGES_REPOSITORY}" == "staging" ]]; then
  BUILDER_ARGS+=" -d staging"
fi

if [[ "${DEBUG}" = "yes" ]]; then
  INSTALL_ARGS+=" -v"
fi

echo "Using ${PACKAGES_REPOSITORY} packages"

. ${ASSETS_PATH}/steps.sh

# Build install script
bash ${RESOURCES_PATH}/${BUILDER} ${BUILDER_ARGS}
CYB3RHQ_VERSION=$(cat ${RESOURCES_PATH}/${INSTALLER} | grep "cyb3rhq_version=" | cut -d "\"" -f 2)

# System configuration
systemConfig

# Edit installation script
preInstall

# Install
bash ${RESOURCES_PATH}/${INSTALLER} ${INSTALL_ARGS}

systemctl stop filebeat cyb3rhq-manager

# Delete indexes
for index in "${INDEXES[@]}"; do
    curl -u admin:admin -XDELETE "https://127.0.0.1:9200/$index" -k
done

# Recreate empty indexes (cyb3rhq-alerts and cyb3rhq-archives)
bash /usr/share/cyb3rhq-indexer/bin/indexer-security-init.sh -ho 127.0.0.1

systemctl stop cyb3rhq-indexer cyb3rhq-dashboard
systemctl enable cyb3rhq-manager


clean
