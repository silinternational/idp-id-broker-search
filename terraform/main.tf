
// Create S3 bucket for uploading binary
resource "aws_s3_bucket" "idp-id-broker-search" {
  bucket        = "${var.app_name}-${var.aws_region}"
  force_destroy = true

  tags = {
    app_name = var.app_name
    app_env  = var.app_env
  }
}

resource "aws_s3_bucket_acl" "idp-id-broker-search" {
  bucket = aws_s3_bucket.idp-id-broker-search
  acl = "public-read"
}

resource "aws_s3_bucket_versioning" "idp-id-broker-search" {
  bucket = aws_s3_bucket.idp-id-broker-search
  versioning_configuration {
    status = "Enabled"
  }
}

// Create a second S3 bucket for uploading binary to a different region (crude form of replication)
resource "aws_s3_bucket" "idp-id-broker-search-2" {
  provider      = aws.secondary
  bucket        = "${var.app_name}-${var.aws_region_secondary}"
  force_destroy = true

  tags = {
    app_name = var.app_name
    app_env  = var.app_env
  }
}

resource "aws_s3_bucket_acl" "idp-id-broker-search-2" {
  bucket = aws_s3_bucket.idp-id-broker-search-2
  acl = "public-read"
}

resource "aws_s3_bucket_versioning" "idp-id-broker-search-2" {
  bucket = aws_s3_bucket.idp-id-broker-search-2
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_user" "ci-uploader" {
  name = "${var.app_name}-uploader"
}

resource "aws_iam_access_key" "ci-uploader" {
  user = aws_iam_user.ci-uploader.name
}

data "template_file" "ci-uploader" {
  template = file("${path.module}/ci-bucket-policy.json")

  vars = {
    bucket_name  = aws_s3_bucket.idp-id-broker-search.bucket
    bucket2_name = aws_s3_bucket.idp-id-broker-search-2.bucket
  }
}

resource "aws_iam_user_policy" "ci-uploader" {
  name = "S3-Access"
  user = aws_iam_user.ci-uploader.name

  policy = data.template_file.ci-uploader.rendered
}
