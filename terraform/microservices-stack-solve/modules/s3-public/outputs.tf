output "bucket_id" {
  value = aws_s3_bucket.public.id
}

output "bucket_domain_name" {
  value       = aws_s3_bucket.public.bucket_domain_name
  description = "Public URL prefix, e.g. https://<this>/your-object-key"
}
