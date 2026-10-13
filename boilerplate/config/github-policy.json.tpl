{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ListAssetBucket",
      "Effect": "Allow",
      "Action": ["s3:ListBucket", "s3:GetBucketLocation"],
      "Resource": "arn:aws:s3:::{{APP_SLUG}}-assets"
    },
    {
      "Sid": "ReadWriteAssetBucket",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:PutObjectAcl"
      ],
      "Resource": "arn:aws:s3:::{{APP_SLUG}}-assets/*"
    },
    {
      "Sid": "RunnerIpWhitelist",
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:DescribeSecurityGroups"
      ],
      "Resource": "*"
    }
  ]
}
