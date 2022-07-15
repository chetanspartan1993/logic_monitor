terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.22.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "sm_role" {
  name = "test_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_policy" "policy" {
  name        = "test_policy"
  path        = "/"
  description = "My test policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_secretsmanager_secret.lm_id.arn}",
          "${aws_secretsmanager_secret.lm_key.arn}"
        ]
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "test-attachment"
  roles      = [aws_iam_role.sm_role.name]
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.sm_role.name
}

resource "aws_secretsmanager_secret" "lm_id" {
  name = "logic_monitor_access_id"
}

resource "aws_secretsmanager_secret_version" "lm_id" {
  secret_id     = aws_secretsmanager_secret.lm_id.id
  secret_string = "CHANGEME"
}

resource "aws_secretsmanager_secret" "lm_key" {
  name = "logic_monitor_access_key"
}

resource "aws_secretsmanager_secret_version" "lm_key" {
  secret_id     = aws_secretsmanager_secret.lm_key.id
  secret_string = "CHANGEME"
}



resource "aws_instance" "foo" {
  ami                  = var.ami_id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.test_profile.name
  user_data            = <<EOF
#! /bin/bash
curl -o getURL.py https://tecores3bucket.s3.amazonaws.com/getURL.py
python getURL.py
chmod +x logicmonitorsetup123.bin
./logicmonitorsetup123.bin
EOF  
}
