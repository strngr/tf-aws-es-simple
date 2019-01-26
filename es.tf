variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "us-east-1"
}
variable "es_domain_name" {
    default = "docs"
}
variable "es_domain_version" {
    default = "6.4"
}
variable "es_domain_instance_count" {
    default = 1
}
variable "es_domain_instance_ebs_volume_size" {
    default = 10
}


provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

# data
data "aws_caller_identity" "current" { }

data "template_file" "cloudwatch_logging_policy" {
  template = "${file("policy/es/cloudwatch_logging.json")}"
}

# resources

resource "aws_cloudwatch_log_group" "es" {
  name = "${var.es_domain_name}_log_group"
}

resource "aws_cloudwatch_log_resource_policy" "es" {
  policy_name     = "${var.es_domain_name}_log_resource_poricy"
  policy_document = "${data.template_file.cloudwatch_logging_policy.rendered}"
}

resource "aws_elasticsearch_domain" "es" {
  depends_on = [
    "aws_cloudwatch_log_group.es",
  ]
  
  domain_name           = "${var.es_domain_name}"
  elasticsearch_version = "${var.es_domain_version}"

  cluster_config {
    instance_type  = "m4.large.elasticsearch"
    instance_count = "${var.es_domain_instance_count}"
  }
  
  ebs_options {
    ebs_enabled = true
    volume_size = "${var.es_domain_instance_ebs_volume_size}"
  }
  
  log_publishing_options {
    cloudwatch_log_group_arn = "${aws_cloudwatch_log_group.es.arn}"
    log_type                 = "ES_APPLICATION_LOGS"
  }
}

resource "aws_cloudwatch_metric_alarm" "es_cpuutilization" {
  depends_on = [
    "aws_elasticsearch_domain.es",
  ]
  
  alarm_name          = "${var.es_domain_name}_cpuutilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ES"
  period              = "300"
  statistic           = "Average"
  threshold           = "75"
  dimensions          = {
    ClientId   = "${data.aws_caller_identity.current.account_id}"
    DomainName = "${aws_elasticsearch_domain.es.domain_name}"
  }
}

output endpoint {
  value = "${aws_elasticsearch_domain.es.endpoint}"
}
output kibana_endpoint {
  value = "${aws_elasticsearch_domain.es.kibana_endpoint}"
}
