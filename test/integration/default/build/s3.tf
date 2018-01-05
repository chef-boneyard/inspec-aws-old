resource "random_id" "bucket_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "aws_demo_bucket_public" {
  bucket        = "aws-demo-s3-bucket-public-${terraform.env}.chef.io"
  acl           = "public-read"
  force_destroy = true
  region        = "us-east-1"
  tags {
    Name        = "aws_demo_bucket_public"
    Environment = "prod"
  }
}

resource "aws_s3_bucket" "aws_demo_bucket_private" {
  bucket        = "aws-demo-s3-bucket-private-${terraform.env}.chef.io"
  acl           = "private"
  force_destroy = true
  region        = "us-east-1"
  tags {
    Name        = "aws_demo_bucket_private"
    Environment = "prod"
  }
}

output "s3_bucket_name_public" {
  value = "aws-demo-s3-bucket-public-${terraform.env}.chef.io"
}

output "s3_bucket_name_private" {
  value = "aws-demo-s3-bucket-private-${terraform.env}.chef.io"
}

# add s3 bucket elements - pub

resource "aws_s3_bucket_object" "public-read" {
  bucket = "${aws_s3_bucket.aws_demo_bucket_public.id}"
  acl    = "public-read"
  key    = "public-pic-read.jpg"
  source = "./data/public-pic.jpg"
  etag   = "${md5(file("./data/public-pic.jpg"))}"

  depends_on = ["aws_s3_bucket.aws_demo_bucket_public"]
}

# add s3 bucket elements - pub Authenticated Users only

resource "aws_s3_bucket_object" "authenticated-read" {
  bucket = "${aws_s3_bucket.aws_demo_bucket_public.id}"
  acl    = "authenticated-read"
  key    = "public-pic-authenticated.jpg"
  source = "./data/public-pic.jpg"
  etag   = "${md5(file("./data/public-pic.jpg"))}"

  depends_on = ["aws_s3_bucket.aws_demo_bucket_public"]
}
# add s3 bucket elements - pri

resource "aws_s3_bucket_object" "private" {
  bucket = "${aws_s3_bucket.aws_demo_bucket_private.id}"
  acl    = "private"
  key    = "private-pic.jpg"
  source = "./data/private-pic.jpg"
  etag   = "${md5(file("./data/private-pic.jpg"))}"

  depends_on = ["aws_s3_bucket.aws_demo_bucket_private"]
}

# add s3 bucket policy elements

resource "aws_s3_bucket_policy" "allow-policy" {
  bucket = "${aws_s3_bucket.aws_demo_bucket_public.id}"
  policy =<<POLICY
{
  "Version": "2012-10-17",
  "Id": "ALLOWPOLICY",
  "Statement": [
    {
      "Sid": "IPAllow",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.aws_demo_bucket_public.id}/*",
      "Condition": {
         "IpAddress": {"aws:SourceIp": "8.8.8.8/32"}
      }
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_policy" "deny-policy" {
  bucket = "${aws_s3_bucket.aws_demo_bucket_private.id}"
  policy =<<POLICY
{
  "Version": "2012-10-17",
  "Id": "DENYPOLICY",
  "Statement": [
    {
      "Sid": "IPAllow",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.aws_demo_bucket_private.id}/*",
      "Condition": {
         "IpAddress": {"aws:SourceIp": "8.8.8.8/32"}
      }
    }
  ]
}
POLICY
}

# valid ACLs are Error: aws_s3_bucket_object.public: "acl" contains an invalid canned ACL type "public". V
#alid types are either "authenticated-read", "aws-exec-read", "bucket-owner-full-control", "bucket-owner-read",
# "private", "public-read", or "public-read-write"
