#! /bin/bash

set -ex

BRANCH=$1
JOBS=$2
DEBUG=$3
REVISION=$4
TRUST_VERIFICATION=$5
CA_NAME=$6
ZIP_NAME="windows_agent_${REVISION}.zip"

URL_REPO=https://github.com/cyb3rhq/cyb3rhq/archive/${BRANCH}.zip

# Download the cyb3rhq repository
wget -O cyb3rhq.zip ${URL_REPO} && unzip cyb3rhq.zip

# Compile the cyb3rhq agent for Windows
FLAGS="-j ${JOBS} IMAGE_TRUST_CHECKS=${TRUST_VERIFICATION} CA_NAME=\"${CA_NAME}\" "

if [[ "${DEBUG}" = "yes" ]]; then
    FLAGS+="-d "
fi

bash -c "make -C /cyb3rhq-*/src deps TARGET=winagent ${FLAGS}"
bash -c "make -C /cyb3rhq-*/src TARGET=winagent ${FLAGS}"

rm -rf /cyb3rhq-*/src/external

# Zip the compiled agent and move it to the shared folder
zip -r ${ZIP_NAME} cyb3rhq-*
cp ${ZIP_NAME} /shared
