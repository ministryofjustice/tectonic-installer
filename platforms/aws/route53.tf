data "null_data_source" "zones" {
  inputs = {
    private = "${var.tectonic_aws_external_private_zone == "" ? join("", aws_route53_zone.tectonic_int.*.zone_id) : var.tectonic_aws_external_private_zone}"
    public  = "${join("", data.aws_route53_zone.tectonic_ext.*.zone_id)}"
  }
}

data "aws_route53_zone" "tectonic_ext" {
  count = "${var.tectonic_aws_public_endpoints}"
  name  = "${var.tectonic_base_domain}"
}

resource "aws_route53_zone" "tectonic_int" {
  count         = "${!var.tectonic_aws_private_endpoints ? 0 : var.tectonic_aws_external_private_zone == "" ? 1 : 0}"
  vpc_id        = "${module.vpc.vpc_id}"
  name          = "${var.tectonic_base_domain}"
  force_destroy = true

  tags = "${merge(map(
      "Name", "${var.tectonic_cluster_name}_tectonic_int_zone",
      "KubernetesCluster", "${var.tectonic_cluster_name}",
      "tectonicClusterID", "${module.tectonic.cluster_id}"
    ), var.tectonic_aws_extra_tags)}"
}
