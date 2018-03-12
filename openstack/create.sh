#!/bin/bash -eu


HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ "$(pwd)" != "{HERE}" ] && cd "${HERE}"
unset HERE


./terraform init
./terraform apply -auto-approve -var-file="settings.tf"

