output "bucket_arn" {
  value = aws_s3_bucket.demo.arn
}

output "queue_url" {
  value = aws_sqs_queue.task_queue.id
}
