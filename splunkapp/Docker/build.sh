#!/bin/bash

cyb3rhq_branch=$1
checksum=$2
revision=$3

cyb3rhq_version=""
splunk_version=""

build_dir="/pkg"
destination_dir="/cyb3rhq_splunk_app"
checksum_dir="/var/local/checksum"
package_json="${build_dir}/package.json"

download_sources() {
    if ! curl -L https://github.com/cyb3rhq/cyb3rhq-splunk/tarball/${cyb3rhq_branch} | tar zx ; then
        echo "Error downloading the source code from GitHub."
        exit 1
    fi
    mv cyb3rhq-* ${build_dir}
    cyb3rhq_version=$(python -c "import json, os; f=open(\""${package_json}"\"); pkg=json.load(f); f.close(); print(pkg[\"version\"])")
    splunk_version=$(python -c "import json, os; f=open(\""${package_json}"\"); pkg=json.load(f); f.close(); print(pkg[\"splunk\"])")}
}

remove_execute_permissions() {
    chmod -R -x+X * ./SplunkAppForCyb3rhq/appserver
}

build_package() {

    download_sources

    cd ${build_dir}

    remove_execute_permissions

    if [ -z ${revision} ]; then
        cyb3rhq_splunk_pkg_name="cyb3rhq_splunk-${cyb3rhq_version}_${splunk_version}.tar.gz"
    else
        cyb3rhq_splunk_pkg_name="cyb3rhq_splunk-${cyb3rhq_version}_${splunk_version}-${revision}.tar.gz"
    fi

    tar -zcf ${cyb3rhq_splunk_pkg_name} SplunkAppForCyb3rhq

    mv ${cyb3rhq_splunk_pkg_name} ${destination_dir}

    if [ ${checksum} = "yes" ]; then
        cd ${destination_dir} && sha512sum "${cyb3rhq_splunk_pkg_name}" > "${checksum_dir}/${cyb3rhq_splunk_pkg_name}".sha512
    fi

    exit 0
}

build_package