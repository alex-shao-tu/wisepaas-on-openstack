# local data
data "local_file" "public_key" {
  filename = "../bosh.pem.pub"
}

# specify provider
provider "openstack" {
  domain_name = "${var.openstack_domain_name}"
  tenant_name = "${var.openstack_tenant_name}"
  user_name = "${var.openstack_user_name}"
  password = "${var.openstack_password}"
  auth_url = "${var.openstack_auth_url}"
  region = "${var.openstack_region_name}"
}

# upload keypair
resource "openstack_compute_keypair_2" "bosh" {
  name = "${var.private_key_os_name}"
  public_key = "${data.local_file.public_key.content}"
}

# upload starter image
resource "openstack_images_image_v2" "starter" {
  name = "${var.starter_os_name}"
  container_format = "bare"
  disk_format = "qcow2"
  local_file_path = "${var.starter_image_path}"
}

# create security group
resource "openstack_networking_secgroup_v2" "nsg" {
  name = "${var.wisepaas_nsg_name}"
}

# set security group rules -- icmp
resource "openstack_networking_secgroup_v2" "icmp" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "icmp"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.nsg.id}"
}

# set security group rules -- cf_tcp_22
resource "openstack_networking_secgroup_v2" "cf_tcp_22" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 22
  port_range_max = 22
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.nsg.id}"
}
# set security group rules -- cf_tcp_80
resource "openstack_networking_secgroup_v2" "cf_tcp_80" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 80
  port_range_max = 80
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.nsg.id}"
}
# set security group rules -- cf_tcp_443
resource "openstack_networking_secgroup_v2" "cf_tcp_443" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 443
  port_range_max = 443
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.nsg.id}"
}
# set security group rules -- cf_tcp_4443
resource "openstack_networking_secgroup_v2" "cf_tcp_4443" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 4443
  port_range_max = 4443
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.nsg.id}"
}
# set security group rules -- cf_udp_68
resource "openstack_networking_secgroup_v2" "cf_udp_68" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "udp"
  port_range_min = 68
  port_range_max = 68
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.nsg.id}"
}
# set security group rules -- cf_udp_3457
resource "openstack_networking_secgroup_v2" "cf_udp_3457" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "udp"
  port_range_min = 3457
  port_range_max = 3457
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.nsg.id}"
}
# set security group rules -- cf_tcp_any2any
resource "openstack_networking_secgroup_v2" "cf_tcp_any2any" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 1
  port_range_max = 65535
  remote_group_id = "${openstack_networking_secgroup_v2.nsg.id}"
  security_group_id = "${openstack_networking_secgroup_v2.nsg.id}"
}
# set security group rules -- cf_udp_any2any
resource "openstack_networking_secgroup_v2" "cf_udp_any2any" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "udp"
  port_range_min = 1
  port_range_max = 65535
  remote_group_id = "${openstack_networking_secgroup_v2.nsg.id}"
  security_group_id = "${openstack_networking_secgroup_v2.nsg.id}"
}

# set security group rules -- director_tcp_25555
resource "openstack_networking_secgroup_v2" "director_tcp_25555" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 25555
  port_range_max = 25555
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.nsg.id}"
}

# set security group rules -- prometheus_tcp_3000
resource "openstack_networking_secgroup_v2" "prometheus_tcp_3000" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 3000
  port_range_max = 3000
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.nsg.id}"
}
# set security group rules -- prometheus_tcp_9090
resource "openstack_networking_secgroup_v2" "prometheus_tcp_9090" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 9090
  port_range_max = 9090
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.nsg.id}"
}
# set security group rules -- prometheus_tcp_9093
resource "openstack_networking_secgroup_v2" "prometheus_tcp_9093" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 9093
  port_range_max = 9093
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.nsg.id}"
}

# set security group rules -- mongo_tcp_27017
resource "openstack_networking_secgroup_v2" "mongo_tcp_27017" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 27017
  port_range_max = 27017
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.nsg.id}"
}

# set security group rules -- postgresql_tcp_5432
resource "openstack_networking_secgroup_v2" "postgresql_tcp_5432" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 5432
  port_range_max = 5432
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.nsg.id}"
}

# set security group rules -- redis_tcp_6379
resource "openstack_networking_secgroup_v2" "redis_tcp_6379" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 6379
  port_range_max = 6379
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.nsg.id}"
}
# set security group rules -- redis_tcp_6380
resource "openstack_networking_secgroup_v2" "redis_tcp_6380" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 6380
  port_range_max = 6380
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.nsg.id}"
}

# set security group rules -- mqtt_tcp_1883
resource "openstack_networking_secgroup_v2" "mqtt_tcp_1883" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 1883
  port_range_max = 1883
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.nsg.id}"
}
# set security group rules -- mqtt_tcp_8883
resource "openstack_networking_secgroup_v2" "mqtt_tcp_8883" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 8883
  port_range_max = 8883
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.nsg.id}"
}

# set security group rules -- amqp_tcp_5671
resource "openstack_networking_secgroup_v2" "amqp_tcp_5671" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 5671
  port_range_max = 5671
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.nsg.id}"
}
# set security group rules -- amqp_tcp_5672
resource "openstack_networking_secgroup_v2" "amqp_tcp_5672" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 5672
  port_range_max = 5672
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.nsg.id}"
}

# set security group rules -- influxdb_tcp_8086
resource "openstack_networking_secgroup_v2" "influxdb_tcp_8086" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 8086
  port_range_max = 8086
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.nsg.id}"
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

  depends_on = [
    "openstack_compute_keypair_2.bosh",
    "openstack_images_image_v2.starter"
  ]

  providioner "local-exec" {
    command = <<EOF
    EOF
  }
}

