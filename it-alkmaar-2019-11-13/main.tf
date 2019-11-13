
variable image_name {
  default = "Ubuntu 18.04 LTS"
}

variable flavor_name {
  default = "t2.tiny"
}

variable prefix {
}

data "template_file" "user_data_template" {
  template = "${file("${path.module}/user_data.yaml")}"

  vars = {
    tf_hostname = "${var.prefix}bionic"
  }
}

data "template_cloudinit_config" "bionic" {
  part {
    content      = "${data.template_file.user_data_template.rendered}"
    content_type = "text/cloud-config"
    filename     = "init.cfg"
  }
}

resource "openstack_compute_instance_v2" "bionic" {
  name        = "${var.prefix}bionic"
  user_data   = "${data.template_cloudinit_config.bionic.rendered}"
  image_name  = "${var.image_name}"
  flavor_name = "${var.flavor_name}"

  network {
    name = "public"
  }

  security_groups = [
    "default",
#    "${openstack_compute_secgroup_v2.secgroup_1.name}",
  ]

}

#resource "openstack_compute_secgroup_v2" "secgroup_1" {
#  name        = "${var.prefix}secgroup"
#  description = "from all allow SSH access"
#
#  rule {
#    from_port   = -1
#    to_port     = -1
#    ip_protocol = "icmp"
#    cidr        = "0.0.0.0/0"
#  }
#
#  rule {
#    from_port   = 22
#    to_port     = 22
#    ip_protocol = "tcp"
#    cidr        = "0.0.0.0/0"
#  }
#
#  rule {
#    from_port   = 80
#    to_port     = 80
#    ip_protocol = "tcp"
#    cidr        = "0.0.0.0/0"
#  }
#}

output "cloud_instance_floating_ip" {
  value = "${openstack_compute_instance_v2.bionic.network[0].fixed_ip_v4}"
}

output "cloud_instance_name" {
  value = "${openstack_compute_instance_v2.bionic.name}"
}

output "cloud_instance_id" {
  value = "${openstack_compute_instance_v2.bionic.id}"
}
