provider "aws" {
  region = "eu-central-1"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "site" {
  bucket = "${lower(data.aws_caller_identity.current.user_id)}-1.tp.exness.business"
  acl    = "public-read"
  force_destroy = true

  website {
    index_document = "index.html"

    routing_rules = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "docs/"
    },
    "Redirect": {
        "ReplaceKeyPrefixWith": "documents/"
    }
}]
EOF
  }
}

resource "null_resource" "remove_and_upload_to_s3" {
  provisioner "local-exec" {
    command = "aws s3 sync ${path.module}/../../website/client/dist/ s3://${aws_s3_bucket.site.id}"
  }
}

resource "aws_s3_bucket_policy" "site" {
  bucket = "${aws_s3_bucket.site.id}"

  policy = <<POLICY
{
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "${aws_s3_bucket.site.arn}/*"
            ]
        }
    ]
}
POLICY
}
output "s3_endpoint" {
  value = "${aws_s3_bucket.site.bucket_regional_domain_name}"
}

output "website_endpoint" {
  value = "${aws_s3_bucket.site.website_endpoint}"
}

output "website_domain" {
  value = "${aws_s3_bucket.site.website_domain}"
}