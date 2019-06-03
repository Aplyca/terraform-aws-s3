locals {
  id = "${replace(var.name, " ", "-")}"
}

resource "aws_s3_bucket" "this" {
  bucket = "${lower(local.id)}"
  acl    = "${var.acl}"
  tags   = "${var.tags}"

  cors_rule {
    allowed_headers = "${var.cors_allowed_headers}"
    allowed_methods = "${var.cors_allowed_methods}"
    allowed_origins = "${var.cors_allowed_origins}"
    expose_headers  = "${var.cors_expose_headers}"
    max_age_seconds = "${var.cors_max_age_seconds}"
  }

  logging = "${var.logging}"

  versioning {
    enabled = "${var.versioning_enabled}"
  }

  website = ["${var.website}"]

  lifecycle_rule = "${var.lifecycle_rule}"
}

resource "aws_s3_bucket_policy" "access_identity" {
  count  = "${var.access_identity ? 1 : 0}"
  bucket = "${aws_s3_bucket.this.id}"
  policy = "${data.template_file.access_identity.rendered}"
}

resource "aws_s3_bucket_policy" "public" {
  count  = "${var.acl == "public-read" ? 1 : 0}"
  bucket = "${aws_s3_bucket.this.id}"
  policy = "${data.template_file.public.rendered}"
}

resource "aws_iam_policy" "read" {
  count       = "${length(var.read_roles) > 0 ? 1 : 0}"
  name        = "${local.id}-S3-Read"
  description = "${var.description} Read"
  policy      = "${data.aws_iam_policy_document.read.json}"
}

resource "aws_iam_role_policy_attachment" "read" {
  count      = "${length(var.read_roles)}"
  role       = "${element(var.read_roles, count.index)}"
  policy_arn = "${aws_iam_policy.read.arn}"
}

resource "aws_iam_policy" "write" {
  count       = "${length(var.write_roles) > 0 ? 1 : 0}"
  name        = "${local.id}-S3-Write"
  description = "${var.description} Write"
  policy      = "${data.aws_iam_policy_document.write.json}"
}

resource "aws_iam_role_policy_attachment" "write" {
  count      = "${length(var.write_roles)}"
  role       = "${element(var.write_roles, count.index)}"
  policy_arn = "${aws_iam_policy.write.arn}"
}
