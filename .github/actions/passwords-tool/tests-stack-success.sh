#!/bin/bash

users=( admin kibanaserver kibanaro logstash readall snapshotrestore )
api_users=( cyb3rhq cyb3rhq-wui )

echo '::group:: Change indexer password, password providing it.'

bash cyb3rhq-passwords-tool.sh -u admin -p LN*X1v.VNtCZ5sESEtLfijPAd39LXGAI
if curl -s -XGET https://localhost:9200/ -u admin:LN*X1v.VNtCZ5sESEtLfijPAd39LXGAI -k -w %{http_code} | grep "401"; then
    exit 1
fi
echo '::endgroup::'

echo '::group:: Change indexer password without providing it.'

indx_pass="$(bash cyb3rhq-passwords-tool.sh -u admin | awk '/admin/{ print $NF }' | tr -d \' )"
if curl -s -XGET https://localhost:9200/ -u admin:"${indx_pass}" -k -w %{http_code} | grep "401"; then
    exit 1
fi

echo '::endgroup::'

echo '::group:: Change all passwords except Cyb3rhq API ones.'

mapfile -t pass < <(bash cyb3rhq-passwords-tool.sh -a | grep 'The password for' | awk '{ print $NF }')
for i in "${!users[@]}"; do
    if curl -s -XGET https://localhost:9200/ -u "${users[i]}":"${pass[i]}" -k -w %{http_code} | grep "401"; then
        exit 1
    fi
done

echo '::endgroup::'

echo '::group:: Change all passwords.'

cyb3rhq_pass="$(cat cyb3rhq-install-files/cyb3rhq-passwords.txt | awk "/username: 'cyb3rhq'/{getline;print;}" | awk '{ print $2 }' | tr -d \' )"

mapfile -t passall < <(bash cyb3rhq-passwords-tool.sh -a -au cyb3rhq -ap "${cyb3rhq_pass}" | grep 'The password for' | awk '{ print $NF }' ) 
passindexer=("${passall[@]:0:6}")
passapi=("${passall[@]:(-2)}")

for i in "${!users[@]}"; do
    if curl -s -XGET https://localhost:9200/ -u "${users[i]}":"${passindexer[i]}" -k -w %{http_code} | grep "401"; then
        exit 1
    fi
done

for i in "${!api_users[@]}"; do
    if curl -s -u "${api_users[i]}":"${passapi[i]}" -w "%{http_code}" -k -X POST "https://localhost:55000/security/user/authenticate" | grep "401"; then
        exit 1
    fi
done

echo '::endgroup::'

echo '::group:: Change single Cyb3rhq API user.'

bash cyb3rhq-passwords-tool.sh -au cyb3rhq -ap "${passapi[0]}" -u cyb3rhq -p BkJt92r*ndzN.CkCYWn?d7i5Z7EaUt63 -A 
    if curl -s -w "%{http_code}" -u cyb3rhq:BkJt92r*ndzN.CkCYWn?d7i5Z7EaUt63 -k -X POST "https://localhost:55000/security/user/authenticate" | grep "401"; then
        exit 1
    fi
echo '::endgroup::'

echo '::group:: Change all passwords except Cyb3rhq API ones using a file.'

mapfile -t passfile < <(bash cyb3rhq-passwords-tool.sh -f cyb3rhq-install-files/cyb3rhq-passwords.txt | grep 'The password for' | awk '{ print $NF }' ) 
for i in "${!users[@]}"; do
    if curl -s -XGET https://localhost:9200/ -u "${users[i]}":"${passfile[i]}" -k -w %{http_code} | grep "401"; then
        exit 1
    fi
done
echo '::endgroup::'

echo '::group:: Change all passwords from a file.'
mapfile -t passallf < <(bash cyb3rhq-passwords-tool.sh -f cyb3rhq-install-files/cyb3rhq-passwords.txt -au cyb3rhq -ap BkJt92r*ndzN.CkCYWn?d7i5Z7EaUt63 | grep 'The password for' | awk '{ print $NF }' )
passindexerf=("${passallf[@]:0:6}")
passapif=("${passallf[@]:(-2)}")

for i in "${!users[@]}"; do
    if curl -s -XGET https://localhost:9200/ -u "${users[i]}":"${passindexerf[i]}" -k -w %{http_code} | grep "401"; then
        exit 1
    fi
done

for i in "${!api_users[@]}"; do
    if curl -s -u "${api_users[i]}":"${passapif[i]}" -w "%{http_code}" -k -X POST "https://localhost:55000/security/user/authenticate" | grep "401"; then
        exit 1
    fi
done

echo '::endgroup::'
