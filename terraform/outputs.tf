output "s3_bucket_name" {
  value = aws_s3_bucket.site.id # pour aws s3 sync
}

output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.site.domain_name}"
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.site.id # pour invalider le cache
}

output "ec2_public_ip" {
  value = aws_instance.web.public_ip # pour inventory.ini
}
