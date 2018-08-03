# Terraform AWS S3 module
=========================

> Create a AWS S3 buckets optimized for static web hosting


## Create a New Public Bucket

``` yaml
module "public_static_bucket" {
  source  = "Aplyca/s3/aws"
  version = "0.1.3"

  name   = "<Your custom Bucket Name>"
  acl = "public-read"
  read_roles = ["<role_name_1>", "<role_name_1>]  Resources with these roles can read the bucket
  write_roles = ["<role_name_3>"] Resources with these roles can write
  website = [{
    index_document = "index.html"
    error_document = "index.html"
  }]

  cors_allowed_origins = ["*"]
  cors_allowed_headers = ["*"]
  cors_allowed_methods = ["GET"]
  cors_expose_headers  = ["ETag"]
  cors_max_age_seconds = "0"

  tags {
    App = "App Name Public Resources"
    Environment = "Development"
  }
}
```

## Create non public Bucket


``` yaml
module "nonpublic_files_bucket" {
  source  = "Aplyca/s3/aws"
  version = "0.1.3"

  name   = "<Your custom Bucket Name>"
  read_roles = ["<role_name_1>"]  Resources with this role can read the bucket
  description = "APP Files Bucket"
  tags {
    App = "APP Name Non Public Resources"
  }
}
```

## How to reference the bucket
>
> Examples using the *nonpublic_files_bucket* sample:
> - Example By Name:
> any_var_bucket_name = "${module.nonpublic_files_bucket.name}"
> - Example By ARN:
> any_var_bucket_arn = "${module.nonpublic_files_bucket.arn}"
> - Example By Domain:
> any_var_bucket_domain = "${module.nonpublic_files_bucket.domain}"


## Resources


This is the list of resources that the module may create. The module can create zero or more of each of these resources depending on the count value. The count value is determined at runtime. The goal of this page is to present the types of resources that may be created.

This list contains all the resources this plus any submodules may create. When using this module, it may create less resources if you use a submodule.

This module defines 7 resources.

- aws_iam_policy.read
- aws_iam_policy.write
- aws_iam_role_policy_attachment.read
- aws_iam_role_policy_attachment.write
- aws_s3_bucket.this
- aws_s3_bucket_policy.access_identity
- aws_s3_bucket_policy.public

## Optional Inputs

These variables have default values and don't have to be set to use this module. You may set these variables to override their default values. This module has no required variables.
- access_identity
- access_identity_arn
- acl
- bucket_domain_format
- cors_allowed_headers
- cors_allowed_methods
- cors_allowed_origins
- cors_expose_headers
- cors_max_age_seconds
- description
- name
- read_permissions
- read_roles
- tags
- website
- write_permissions
- write_roles

For more reference please check in the Terraform Module Registry: https://registry.terraform.io/modules/Aplyca/s3/aws/0.1.3
