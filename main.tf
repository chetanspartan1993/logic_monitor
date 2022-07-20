terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.22.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_launch_template" "foobar" {
  name_prefix   = var.name_prefix
  image_id      = var.ami_id
  instance_type = var.instance_type
  user_data     = filebase64("${path.module}/script.sh")
  vpc_security_group_ids = [aws_security_group.custom.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.test_profile.name
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = var.volume_size
      encrypted = true
      kms_key_id = module.kms_key.key_id
    }
  }
}

resource "aws_autoscaling_group" "bar" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size

  launch_template {
    id      = aws_launch_template.foobar.id
    version = "$Latest"
  }

  depends_on = [
    aws_iam_instance_profile.test_profile,
    aws_secretsmanager_secret_version.lm_id,
    aws_secretsmanager_secret_version.lm_key,
    aws_security_group.custom,
    aws_security_group_rule.outbound
  ]
}

module "iam_role" {
  source  = "../iac-framework-modules-feature-tf13/iam/role"
  
  rolename = var.role_name

  policyname = var.policy_name

  policydescription = var.policy_description
  
  assumerolepolicy = jsonencode({
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

module "kms_key" {
  source  = "../iac-framework-modules-feature-tf13/kms"

  description = "CMK key for encryption"
  key_deletion_window = var.key_deletion_window
  key_alias = var.alias_name_key
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = var.role_name
  depends_on = [
    module.iam_role
  ]
}

resource "aws_secretsmanager_secret" "lm_id" {
  name = "logic_monitor_access_id"
  kms_key_id = module.kms_key.key_id
}

resource "aws_secretsmanager_secret_version" "lm_id" {
  secret_id     = aws_secretsmanager_secret.lm_id.id
  secret_string = "CHANGEME"
}

resource "aws_secretsmanager_secret" "lm_key" {
  name = "logic_monitor_access_key"
  kms_key_id = module.kms_key.key_id
}

resource "aws_secretsmanager_secret_version" "lm_key" {
  secret_id     = aws_secretsmanager_secret.lm_key.id
  secret_string = "CHANGEME"
}

resource "aws_security_group" "custom" {
  name        = var.security_group_name
  description = "Security group for logic monitor collector instances"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  description       = "Outbound"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.custom.id
}
