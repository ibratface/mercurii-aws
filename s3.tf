resource "aws_s3_bucket" "frontend" {
  bucket = "frontend.mercurii.com"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_s3_bucket_policy" "frontend" {
  depends_on = ["aws_s3_bucket.frontend"]
  bucket = "${aws_s3_bucket.frontend.id}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::frontend.mercurii.com/*"
            ]
        }
    ]
}
POLICY
}