#!/bin/bash

set -ex

# Script parameters
cyb3rhq_branch=$1
checksum=$2
app_revision=$3

# Paths
kibana_dir="/tmp/source"
source_dir="${kibana_dir}/plugins/cyb3rhq"
build_dir="${source_dir}/build"
destination_dir="/cyb3rhq_app"
checksum_dir="/var/local/checksum"
git_clone_tmp_dir="/tmp/cyb3rhq-app"

# Repositories URLs
cyb3rhq_app_clone_repo_url="https://github.com/cyb3rhq/cyb3rhq-dashboard-plugins.git"
cyb3rhq_app_raw_repo_url="https://raw.githubusercontent.com/cyb3rhq/cyb3rhq-dashboard-plugins"
kibana_app_repo_url="https://github.com/elastic/kibana.git"
kibana_app_raw_repo_url="https://raw.githubusercontent.com/elastic/kibana"
cyb3rhq_app_package_json_url="${cyb3rhq_app_raw_repo_url}/${cyb3rhq_branch}/plugins/main/package.json"

# Script vars
cyb3rhq_version=""
kibana_version=""
kibana_yarn_version=""
kibana_node_version=""
aux_kibana_version=""


change_node_version () {
    installed_node_version="$(node -v)"
    node_version=$1

    n ${node_version}

    if [[ "${installed_node_version}" != "v${node_version}" ]]; then
        mv /usr/local/bin/node /usr/bin
        mv /usr/local/bin/npm /usr/bin
        mv /usr/local/bin/npx /usr/bin
    fi

    echo "Using $(node -v) node version"
}


prepare_env() {
    echo "Downloading package.json from cyb3rhq-dashboard-plugins repository"
    if ! curl $cyb3rhq_app_package_json_url -o "/tmp/package.json" ; then
        echo "Error downloading package.json from GitHub."
        exit 1
    fi

    cyb3rhq_version=$(python -c 'import json, os; f=open("/tmp/package.json"); pkg=json.load(f); f.close();\
                    print(pkg["version"])')
    kibana_version=$(python -c 'import json, os; f=open("/tmp/package.json"); pkg=json.load(f); f.close();\
                    plugin_platform_version=pkg.get("pluginPlatform", {}).get("version") or pkg.get("kibana", {}).get("version");\
                    print(plugin_platform_version)')
    aux_kibana_version=$kibana_version

    if [ "${cyb3rhq_version}" \< "4.2.2" ] && [ "${kibana_version}" \> "7.10.2" ]; then
        aux_kibana_version="7.10.2"
    fi

    kibana_package_json_url="${kibana_app_raw_repo_url}/v${aux_kibana_version}/package.json"

    echo "Downloading package.json from elastic/kibana repository"
    if ! curl $kibana_package_json_url -o "/tmp/package.json" ; then
        echo "Error downloading package.json from GitHub."
        exit 1
    fi

    kibana_node_version=$(python -c 'import json, os; f=open("/tmp/package.json"); pkg=json.load(f); f.close();\
                          print(pkg["engines"]["node"])')

    kibana_yarn_version=$(python -c 'import json, os; f=open("/tmp/package.json"); pkg=json.load(f); f.close();\
                          print(pkg["engines"]["yarn"])')
}


download_kibana_sources() {
    if ! git clone $kibana_app_repo_url --branch "v${aux_kibana_version}" --depth=1 kibana_source; then
        echo "Error downloading Kibana source code from elastic/kibana GitHub repository."
        exit 1
    fi

    mkdir -p kibana_source/plugins
    mv kibana_source ${kibana_dir}
}


install_dependencies () {
    cd ${kibana_dir}
    change_node_version $kibana_node_version
    npm install -g "yarn@${kibana_yarn_version}"
    if [ "${aux_kibana_version}" \< "7.11.0" ]; then
        sed -i 's/node scripts\/build_ts_refs/node scripts\/build_ts_refs --allow-root/' ${kibana_dir}/package.json
        sed -i 's/node scripts\/register_git_hook/node scripts\/register_git_hook --allow-root/' ${kibana_dir}/package.json
    fi
    yarn kbn bootstrap --skip-kibana-plugins --oss #--allow-root
}


download_cyb3rhq_app_sources() {
    if ! git clone $cyb3rhq_app_clone_repo_url --branch ${cyb3rhq_branch} --depth=1 ${git_clone_tmp_dir} ; then
        echo "Error downloading the source code from cyb3rhq-dashboard-plugins GitHub repository."
        exit 1
    fi

    cp -r ${git_clone_tmp_dir}/plugins/main ${kibana_dir}/plugins/cyb3rhq
}


build_package(){

    cd $source_dir

    # Set pkg name
    if [ -z "${app_revision}" ]; then
        cyb3rhq_app_pkg_name="cyb3rhq_kibana-${cyb3rhq_version}_${kibana_version}.zip"
    else
        cyb3rhq_app_pkg_name="cyb3rhq_kibana-${cyb3rhq_version}_${kibana_version}-${app_revision}.zip"
    fi

    # Build the package
    yarn
    if [ "${aux_kibana_version}" \< "7.11.0"  ]; then
        KIBANA_VERSION=${kibana_version} yarn build --allow-root
    else
        KIBANA_VERSION=${kibana_version} yarn build
    fi

    find ${build_dir} -name "*.zip" -exec mv {} ${destination_dir}/${cyb3rhq_app_pkg_name} \;

    if [ "${checksum}" = "yes" ]; then
        cd ${destination_dir} && sha512sum "${cyb3rhq_app_pkg_name}" > "${checksum_dir}/${cyb3rhq_app_pkg_name}".sha512
    fi

    exit 0
}


prepare_env
download_kibana_sources
install_dependencies
download_cyb3rhq_app_sources
build_package
