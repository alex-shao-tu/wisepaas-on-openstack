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

# upload keypair
resource "openstack_compute_keypair_v2" "bosh" {
  name = "${var.private_key_os_name}"
  public_key = "${replace("${file("bosh.pub")}", "\n", "")}"
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
    "openstack_images_image_v2.starter"
  ]

  provisioner "local-exec" {
    command = <<EOF
    EOF
  }
}

# associate fixed/floating IP with starter instance
resource "openstack_compute_floatingip_associate_v2" "starter" {
  floating_ip = "${openstack_networking_floatingip_v2.starter.address}"
  instance_id = "${openstack_compute_instance_v2.starter.id}"
  fixed_ip = "${openstack_compute_instance_v2.starter.network.0.fixed_ip_v4}"
}
