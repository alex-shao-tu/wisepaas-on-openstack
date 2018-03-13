#!/bin/bash -eu


export HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ "$(pwd)" != "{HERE}" ] && cd "${HERE}"
export PATH=${HERE}/utils:$PATH
unset HERE

# log all HTTP requests/responses between Terraform and the OpenStack cloud
#export OS_DEBUG=1
#export TF_LOG="DEBUG"

# generate the private key to be widely used in OCF
if [ ! -e "bosh.pem" -a ! -e "bosh.pub" ]; then
    ssh-keygen -t rsa -N '' -f bosh.pem
    mv bosh.pem.pub bosh.pub
fi

# create all required resources on OpenStack
terraform init openstack
terraform apply -auto-approve openstack

