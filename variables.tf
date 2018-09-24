variable "name" {
  description = "Name prefix for all CloudFront resources."
  default     = "App"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. map('BusinessUnit`,`XYZ`)"
}

variable "bucket_domain_format" {
  default = "%s.s3.amazonaws.com"
}

variable "cors_allowed_headers" {
  type    = "list"
  default = ["*"]
}

variable "cors_allowed_methods" {
  type    = "list"
  default = ["GET"]
}

variable "cors_allowed_origins" {
  type    = "list"
  default = ["*"]
}

variable "cors_expose_headers" {
  type    = "list"
  default = ["ETag"]
}

variable "cors_max_age_seconds" {
  default = "0"
}

variable "access_identity_arn" {
  default = ""
}

variable "access_identity" {
  default = false
}

variable "read_permissions" {
  default = [
    "s3:GetObject",
    "s3:ListBucket"
  ]

  type        = "list"
  description = "Recieve permissions granted to assumed role"
}

variable "write_permissions" {
  default = [
    "s3:PutObject",
    "s3:DeleteObject"
  ]

  type        = "list"
  description = "Send permissions granted to assumed role"
}

variable "description" {
  description = "Description of policy"
  default     = ""
}

variable "write_roles" {
  description = "Write permissions roles name"
  default     = []
}

variable "read_roles" {
  description = "Read roles name"
  default     = []
}

variable "acl" {
  description = "ACL"
  default     = "private"
}

variable "website" {
  description = "Website settings"
  default     = []
}

variable "versioning_enabled" {
  description = "Enable versioning of bucket objects"
  default     = false
}
