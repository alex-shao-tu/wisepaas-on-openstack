#!/bin/bash -eu


export HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ "$(pwd)" != "{HERE}" ] && cd "${HERE}"
unset HERE


# log all HTTP requests/responses between Terraform and the OpenStack cloud
export OS_DEBUG=1
export TF_LOG="DEBUG"

# generate the private key to be widely used in OCF
[ -e "bosh.pem" ] || ssh-keygen -t rsa -N '' -f bosh.pem

# create all required resources on OpenStack
openstack/create.sh

