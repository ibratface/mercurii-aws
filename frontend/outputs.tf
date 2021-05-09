output "s3_bucket_name" {
  value = aws_s3_bucket.frontend.id
}

output "website_endpoint" {
  value = aws_s3_bucket.frontend.website_endpoint
}

output "website_domain" {
  value = aws_s3_bucket.frontend.website_domain
}