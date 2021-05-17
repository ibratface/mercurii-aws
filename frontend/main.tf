resource "aws_s3_bucket" "frontend" {
  bucket = "www.${var.domain}.com"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  force_destroy = true
}

resource "aws_s3_bucket_policy" "frontend" {
  depends_on = [aws_s3_bucket.frontend]
  bucket     = aws_s3_bucket.frontend.id
  policy     = templatefile("${path.module}/policy.json", {
    env = var.env
    domain = var.domain
  })
}
