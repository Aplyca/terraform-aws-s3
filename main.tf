terraform {
  required_version = ">= 0.12.0"
}

locals {
  id = replace(var.name, " ", "-")
}

resource "aws_s3_bucket" "this" {
  bucket = lower(local.id)
  acl    = var.acl
  tags   = var.tags

  cors_rule {
    allowed_headers = var.cors_allowed_headers
    allowed_methods = var.cors_allowed_methods
    allowed_origins = var.cors_allowed_origins
    expose_headers  = var.cors_expose_headers
    max_age_seconds = var.cors_max_age_seconds
  }

  dynamic "logging" {
    for_each = var.logging
    content {
      target_bucket = lookup(logging.value, "target_bucket")
      target_prefix = lookup(logging.value, "target_prefix", null)
    }
  }

  versioning {
    enabled = var.versioning_enabled
  }

  dynamic "website" {
    for_each = var.website
    content {
      index_document           = lookup(website.value, "index_document")
      error_document           = lookup(website.value, "error_document", null)
      redirect_all_requests_to = lookup(website.value, "redirect_all_requests_to", null)
      routing_rules            = lookup(website.value, "routing_rules", null)
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rule
    content {
      id                                     = lookup(lifecycle_rule.value, "id", null)
      prefix                                 = lookup(lifecycle_rule.value, "prefix", null)
      tags                                   = lookup(lifecycle_rule.value, "tags", null)
      enabled                                = lookup(lifecycle_rule.value, "enabled")
      abort_incomplete_multipart_upload_days = lookup(lifecycle_rule.value, "abort_incomplete_multipart_upload_days", null)

      dynamic "expiration" {
        for_each = lookup(lifecycle_rule.value, "expiration", [])
        content {
          days                         = lookup(expiration.value, "days", null)
          date                         = lookup(expiration.value, "date", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      dynamic "transition" {
        for_each = lookup(lifecycle_rule.value, "transition", [])
        content {
          days          = lookup(transition.value, "days", null)
          date          = lookup(transition.value, "date", null)
          storage_class = lookup(transition.value, "storage_class")
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = lookup(lifecycle_rule.value, "noncurrent_version_expiration", [])
        content {
          days = lookup(noncurrent_version_expiration.value, "days")
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lookup(lifecycle_rule.value, "noncurrent_version_transition", [])
        content {
          days          = lookup(noncurrent_version_transition.value, "days")
          storage_class = lookup(noncurrent_version_transition.value, "storage_class")
        }
      }
    }
  }
  
  dynamic "replication_configuration" {
    for_each = var.replication_role != "" ? [var.replication_role] : []
    content {
      role = var.replication_role
      dynamic rules {
        for_each = var.replication_rules
        content {
          id     = rules.value.id
          prefix = lookup(rules.value, "rules-prefix", null)
          status = rules.value.status
          destination {
            bucket        = rules.value.destination-bucket
            storage_class = rules.value.destination-storage_class
          }
        }
      }
    }
  
}

resource "aws_s3_bucket_policy" "access_identity" {
  count  = var.access_identity ? 1 : 0
  bucket = aws_s3_bucket.this.id
  policy = element(data.template_file.access_identity.*.rendered, 0)
}

resource "aws_s3_bucket_policy" "public" {
  count  = var.acl == "public-read" ? 1 : 0
  bucket = aws_s3_bucket.this.id
  policy = element(data.template_file.public.*.rendered, 0)
}

resource "aws_iam_policy" "read" {
  count       = length(var.read_roles) > 0 ? 1 : 0
  name        = "${local.id}-S3-Read"
  description = "${var.description} Read"
  policy      = data.aws_iam_policy_document.read.json
}

resource "aws_iam_role_policy_attachment" "read" {
  count      = length(var.read_roles)
  role       = element(var.read_roles, count.index)
  policy_arn = element(aws_iam_policy.read.*.arn, 0)
}

resource "aws_iam_policy" "write" {
  count       = length(var.write_roles) > 0 ? 1 : 0
  name        = "${local.id}-S3-Write"
  description = "${var.description} Write"
  policy      = data.aws_iam_policy_document.write.json
}

resource "aws_iam_role_policy_attachment" "write" {
  count      = length(var.write_roles)
  role       = element(var.write_roles, count.index)
  policy_arn = element(aws_iam_policy.write.*.arn, 0)
}
