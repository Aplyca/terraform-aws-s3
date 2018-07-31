data "aws_iam_policy_document" "access_identity" {
  count = "${var.access_identity ? 1 : 0}"
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::$${bucket_name}$${origin_path}*"]

    principals {
      type        = "AWS"
      identifiers = ["${var.access_identity_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::$${bucket_name}"]

    principals {
      type        = "AWS"
      identifiers = ["${var.access_identity_arn}"]
    }
  }
}

data "template_file" "access_identity" {
  count = "${var.access_identity ? 1 : 0}"
  template = "${data.aws_iam_policy_document.access_identity.json}"

  vars {
    origin_path = "/"
    bucket_name = "${aws_s3_bucket.this.id}"
  }
}

data "aws_iam_policy_document" "read" {
  statement {
    actions = [
      "${var.read_permissions}"
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "write" {
  statement {
    actions = [
      "${var.write_permissions}"
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]
  }
}


data "aws_iam_policy_document" "public" {
  count = "${var.acl == "public-read" ? 1 : 0}"
  statement {
    actions = [
      "${var.read_permissions}"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]
  }
}

data "template_file" "public" {
  count = "${var.acl == "public-read" ? 1 : 0}"
  template = "${data.aws_iam_policy_document.public.json}"
}

data "template_file" "write" {
  count = "${var.acl == "public-read" ? 1 : 0}"
  template = "${data.aws_iam_policy_document.write.json}"
}
