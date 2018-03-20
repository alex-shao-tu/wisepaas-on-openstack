#!/bin/bash -eu


export HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ "$(pwd)" != "{HERE}" ] && cd "${HERE}"
export PATH=${HERE}/utils:$PATH
unset HERE


# log all HTTP requests/responses between Terraform and the OpenStack cloud
#export OS_DEBUG=1
#export TF_LOG="DEBUG"


# generate private key
if [ ! -e "bosh.pem" -a ! -e "bosh.pub" ]; then
    ssh-keygen -t rsa -N '' -f bosh.pem
    mv bosh.pem.pub bosh.pub
fi

# run Terraform
(
    cd openstack
    terraform init
    terraform apply -auto-approve
)

# created after executing Terraform
source site.rc

# populate bosh-login.sh onto starter
ssh -i bosh.pem ubuntu@${STARTER_IP} "sudo bash -eus" -- << 'BOSH_LOGIN'
cat << '__SCRIPT__' > /opt/spacex/bosh-login.sh
#!/bin/bash -eu

cd /opt/spacex
export BOSH_ADMIN_PASSWORD="$(bosh int creds.yml --path /admin_password)"

bosh -n -e spacex login << EOF
admin
${BOSH_ADMIN_PASSWORD}
EOF

unset BOSH_ADMIN_PASSWORD
__SCRIPT__

chmod 0755 /opt/spacex/bosh-login.sh
BOSH_LOGIN

# remote actions on starter
ssh -i bosh.pem ubuntu@${STARTER_IP} "sudo bash -eus" -- << EOF
# create BOSH director
bosh -n --tty create-env /opt/spacex/workspaces/bosh-deployment/bosh.yml \
    --state=/opt/spacex/state.json \
    --vars-store=/opt/spacex/creds.yml \
    -o /opt/spacex/workspaces/bosh-deployment/openstack/cpi.yml \
    -o /opt/spacex/workspaces/bosh-deployment/uaa.yml \
    -v director_name=${DIRECTOR_NAME} \
    -v internal_cidr=${INTERNAL_CIDR} \
    -v internal_gw=${INTERNAL_GW} \
    -v internal_ip=${INTERNAL_IP} \
    -v auth_url=${AUTH_URL} \
    -v az=${AZ} \
    -v default_key_name=${DEFAULT_KEY_NAME} \
    -v default_security_groups=${DEFAULT_SECURITY_GROUPS} \
    -v net_id=${NET_ID} \
    -v openstack_username=${OS_USERNAME} \
    -v openstack_password=${OS_PASSWORD} \
    -v openstack_domain=${OS_DOMAIN} \
    -v openstack_project=${OS_PROJECT} \
    -v region=${OS_REGION} \
    -v private_key=${DEFAULT_KEY_NAME}.pem

# alias created BOSH director
bosh -n --tty -e ${INTERNAL_IP} alias-env spacex \
    --ca-cert <(bosh int /opt/spacex/creds.yml --path /director_ssl/ca)

# log into BOSH
/opt/spacex/bosh-login.sh
EOF

# upload BOSH releases, stemcells
ssh -i bosh.pem ubuntu@${STARTER_IP} "sudo bash -eus" -- << 'EOF'
for tgz in /opt/spacex/releases/*.tgz; do
    bosh -n --tty -e spacex upload-release ${tgz}
done

for tgz in /opt/spacex/stemcells/*.tgz; do
    bosh -n --tty -e spacex upload-stemcell ${tgz}
done

unset tgz
EOF

# all done, go to start from now on
exec ssh -i bosh.pem ubuntu@${STARTER_IP}
