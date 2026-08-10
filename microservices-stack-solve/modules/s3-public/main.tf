# =========================================================
# ⚠️  PUBLIC BUCKET — anything uploaded here is readable by
# anyone on the internet with the object URL, no auth required.
# Use this only for content that's genuinely meant to be public
# (e.g. public marketing assets, downloadable files) — never for
# user documents, PII, or anything from the private "assets"
# bucket in modules/s3. That bucket (module.s3_assets) stays
# fully private by design; this is a separate, deliberate bucket.
# =========================================================
resource "aws_s3_bucket" "public" {
  bucket = "${var.bucket_name}-${var.environment}"

  tags = {
    Environment = var.environment
    Access      = "public-read"
  }
}

# Explicitly allow the public policy below to take effect —
# by default AWS blocks it even if you attach one.
resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.public.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Public READ only — not write. Nobody can upload/delete without
# your own credentials; they can only GET objects you've put there.
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.public.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadOnly"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.public.arn}/*"
    }]
  })

  depends_on = [aws_s3_bucket_public_access_block.public]
}

resource "aws_s3_bucket_versioning" "public" {
  bucket = aws_s3_bucket.public.id

  versioning_configuration {
    status = "Enabled"
  }
}
