{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "MediaBucketAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::{{APP_SLUG}}-media",
        "arn:aws:s3:::{{APP_SLUG}}-media/*",
        "arn:aws:s3:::{{APP_SLUG}}-assets",
        "arn:aws:s3:::{{APP_SLUG}}-assets/*"
      ]
    }
  ]
}
