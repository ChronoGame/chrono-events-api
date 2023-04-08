resource "aws_s3_bucket" "csv_bucket" {
  bucket        = "${var.project_name}"
  force_destroy = "false"
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
  acl = "public-read"
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.csv_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_object" "csv_file" {
  bucket = aws_s3_bucket.csv_bucket.bucket
  key    = "events.tsv"
  source = "${path.module}/events.tsv"
  acl    = "private"
}

resource "aws_s3_bucket" "stats_bucket" {
  bucket        = "${var.project_name}-stats"
  force_destroy = true
}