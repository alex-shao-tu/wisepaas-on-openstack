# The Identity authentication URL.
# Normally this value must be corrected based on real environment.
variable "openstack_auth_url" {
  default = "http://:5000/v3"
}

# The OCF starter instance image to be uploaded onto OpenStack.
# Normally not necessary to modify this.
variable "starter_image_path" {
  default = "starter.qcow2"
}

# The name of the Domain to scope to (Identity v3).
# Normally not necessary to modify this.
variable "openstack_domain_name" {
  default = "default"
}

# The name of the Tenant (Identity v2) or Project (Identity v3) to login with.
# Normally not necessary to modify this.
variable "openstack_tenant_name" {
  default = "WISE-PaaS"
}

# The username to login with.
# Normally not necessary to modify this.
variable "openstack_user_name" {
  default = "admin"
}

# The password to login with.
# Normally not necessary to modify this.
variable "openstack_password" {
  default = "P@ssw0rd"
}

# The region of the OpenStack cloud to use.
# Normally not necessary to modify this.
variable "openstack_region_name" {
  default = "RegionOne"
}

# The name of the pool from which to obtain the floating IP.
# Normally not necessary to modify this.
variable "openstack_floatingip_pool_name" {
  default = "public"
}

# The private key name to be used in OpenStack for OCF environment.
# Normally not necessary to modify this.
variable "private_key_os_name" {
  default = "bosh"
}

# The name to be used in OpenStack for OCF starter instance.
# Normally not necessary to modify this.
variable "starter_os_name" {
  default = "starter"
}

# The flavor to be used for launching OCF starter instance in OpenStack.
# Normally not necessary to modify this.
variable "starter_flavor_name" {
  default = "m1.small"
}

# The network security group name to be used for WISE-PaaS in OpenStack.
# Normally not necessary to modify this.
variable "wisepaas_nsg_name" {
  default = "WISE-PaaS-nsg"
}

# The Admin Tenant network name to be used in OpenStack.
# Normally not necessary to modify this.
variable "wisepaas_vnet_name" {
  default = "WISE-PaaS-vnet"
}

