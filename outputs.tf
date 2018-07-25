output "domain" {
  value = "${aws_s3_bucket.this.bucket_domain_name}"
}

output "arn" {
  value = "${aws_s3_bucket.this.arn}"
}
