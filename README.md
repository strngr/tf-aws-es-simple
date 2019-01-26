# Description

This repository contains terraform config for simple Elasticsearch deployment on AWS


# Installation

Let's assume that you already have installed terraform. If no - please follow installation instructions on terraform official website: https://www.terraform.io/downloads.html
Otherwise run in repo root:

you will be asked for you AWS credentials (access and secret keys). You also can put them to `terraform.tfvars` file.

```
terraform plan
```

to see what's going to be deployed. And run: 

```
terraform apply
```

if everything is fine for you.


# Variables

This terraform config has several variables that allows to customize your ES cluster. You can pass this variable direct to terraform command, but it might be more handy to put them to `overrides.tf` file

| variable name | default value | description |
|---|---|---|---|---|
| es_domain_name | docs | elasticsearch domain name. should be unique within account |
| es_domain_version | 6.4 | elasticsearch version |
| es_domain_instance_count | 1 | elasticsearch instances count |
| es_domain_instance_ebs_volume_size | 10 | ebs volume size in GB |


