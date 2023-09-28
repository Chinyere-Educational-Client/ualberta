resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucketname
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.mybucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.mybucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.mybucket.id
  acl    = "public-read"
}

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.mybucket.id
  key    = "index.html"
  source = "index.html"
  acl = "public-read"
  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.mybucket.id
  key    = "error.html"
  source = "error.html"
  acl = "public-read"
  content_type = "text/html"
}

resource "aws_s3_object" "profile" {
  bucket = aws_s3_bucket.mybucket.id
  key    = "profile.png"
  source = "profile.png"
  acl = "public-read"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.mybucket.id
  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  depends_on = [ aws_s3_bucket_acl.example ]
  }

resource "aws_iam_policy" "s3_put_object_policy" {
  name        = "s3-put-object-policy"
  description = "Policy to allow PutObject in an S3 bucket"

  # Define the policy document
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"  # If you want to allow setting object ACLs as well
        ],
        Resource = [
          "arn:aws:s3:::terraformprojectchizzy1/*"  # Replace with your bucket name
        ]
      }
    ]
  })
}

resource "aws_iam_user" "example_user" {
  name = "chinenye"
}

resource "aws_iam_policy_attachment" "attach_s3_put_object_policy" {
  name       = "attach-s3-put-object-policy"
  policy_arn = aws_iam_policy.s3_put_object_policy.arn
  users      = [aws_iam_user.example_user.name]
}
