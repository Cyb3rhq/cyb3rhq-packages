#!/bin/bash
set -e

cyb3rhq_branch=$1

download_sources() {
    if ! curl -L https://github.com/cyb3rhq/cyb3rhq-puppet/tarball/${cyb3rhq_branch} | tar zx ; then
        echo "Error downloading the source code from GitHub."
        exit 1
    fi
    cd cyb3rhq-*
}

build_module() {

    download_sources

    pdk build --force --target-dir=/tmp/output/

    exit 0
}

build_module
