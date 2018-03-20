terraform {
  required_version = "~> 0.11.0"  # use terraform 0.11.x
}

# specify provider
provider "openstack" {
  version = "~> 1.2.0"  # use provider 1.2.x

  domain_name = "${var.openstack_domain_name}"
  tenant_name = "${var.openstack_tenant_name}"
  user_name = "${var.openstack_user_name}"
  password = "${var.openstack_password}"
  auth_url = "${var.openstack_auth_url}"
  region = "${var.openstack_region_name}"
}

# use this data source to get the ID of WISE-PaaS-vnet
data "openstack_networking_network_v2" "wisepaas_vnet" {
  name = "${var.wisepaas_vnet_name}"
}

# upload keypair
resource "openstack_compute_keypair_v2" "bosh" {
  name = "${var.private_key_os_name}"
  public_key = "${replace("${file("../bosh.pub")}", "\n", "")}"
}

# upload starter image
resource "openstack_images_image_v2" "starter" {
  name = "${var.starter_os_name}"
  container_format = "bare"
  disk_format = "qcow2"
  local_file_path = "${var.starter_image_path}"
}

# allocate a floating ip for starter
resource "openstack_networking_floatingip_v2" "starter" {
  pool = "${var.openstack_floatingip_pool_name}"
}

# create starter vm
resource "openstack_compute_instance_v2" "starter" {
  name = "${var.starter_os_name}"
  image_id = "${openstack_images_image_v2.starter.id}"
  flavor_name = "${var.starter_flavor_name}"
  security_groups = ["${var.wisepaas_nsg_name}"]
  key_pair = "${var.private_key_os_name}"

  network = {
    name = "${var.wisepaas_vnet_name}"
  }

  network = {
    name = "${var.openstack_floatingip_pool_name}"
  }

  depends_on = [
    "openstack_compute_keypair_v2.bosh",
    "openstack_images_image_v2.starter",
    "openstack_networking_floatingip_v2.starter"
  ]

  # create site.rc
  provisioner "local-exec" {
    command = <<EOF
      echo "#" > ../site.rc
      echo "# environments of beening deployed site" >> ../site.rc
      echo "#" >> ../site.rc
      echo export STARTER_IP=${openstack_compute_instance_v2.starter.floating_ip} >> ../site.rc
      echo export DIRECTOR_NAME=${var.director_name} >> ../site.rc
      echo export INTERNAL_CIDR=${var.internal_cidr} >> ../site.rc
      echo export INTERNAL_GW=${var.internal_gw} >> ../site.rc
      echo export INTERNAL_IP=${var.internal_ip} >> ../site.rc
      echo export AUTH_URL=${var.openstack_auth_url} >> ../site.rc
      echo export AZ=${var.az} >> ../site.rc
      echo export DEFAULT_KEY_NAME=${var.private_key_os_name} >> ../site.rc
      echo export DEFAULT_SECURITY_GROUPS=[${var.wisepaas_nsg_name}] >> ../site.rc
      echo export NET_ID=${data.openstack_networking_network_v2.wisepaas_vnet.id} >> ../site.rc
      echo export OS_USERNAME=${var.openstack_user_name} >> ../site.rc
      echo export OS_PASSWORD=${var.openstack_password} >> ../site.rc
      echo export OS_DOMAIN=${var.openstack_domain_name} >> ../site.rc
      echo export OS_PROJECT=${var.openstack_tenant_name} >> ../site.rc
      echo export OS_REGION=${var.openstack_region_name} >> ../site.rc
      chmod 0644 ../site.rc
    EOF
  }

  # create go-starter.sh for convenient
  provisioner "local-exec" {
    command = <<EOF
      echo "#!/bin/bash -eu" > ../go-starter.sh
      echo "" >> ../go-starter.sh
      echo "" >> ../go-starter.sh
      echo "ssh -i bosh.pem ubuntu@${openstack_compute_instance_v2.starter.floating_ip}" >> ../go-starter.sh
      echo "" >> ../go-starter.sh
      chmod 0755 ../go-starter.sh
    EOF
  }
}

# associate fixed/floating IP with starter instance
resource "openstack_compute_floatingip_associate_v2" "starter" {
  floating_ip = "${openstack_networking_floatingip_v2.starter.address}"
  instance_id = "${openstack_compute_instance_v2.starter.id}"
  fixed_ip = "${openstack_compute_instance_v2.starter.network.0.fixed_ip_v4}"
}
