#===============================================================================
# Security Groups
#===============================================================================

resource "aws_security_group" "codebuild" {
  name   = "CodeBuildSecurityGroup"
  vpc_id = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "db" {
  name   = "RDSSecurityGroup"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.codebuild.id]
    # cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
  }
}

#===============================================================================
# Codebuild Role
#===============================================================================

resource "aws_iam_policy" "codebuild_vpc" {
  name   = "mercurii-codebuild-vpc"
  policy = file("${path.module}/codebuild-vpc-policy.json")
}

resource "aws_iam_policy" "codebuild_log" {
  name   = "mercurii-codebuild-log"
  policy = file("${path.module}/codebuild-log-policy.json")
}

resource "aws_iam_policy" "codebuild_codecommit" {
  name   = "mercurii-codebuild-codecommit"
  policy = file("${path.module}/codebuild-codecommit-policy.json")
}

resource "aws_iam_policy" "codebuild_rds" {
  name   = "mercurii-codebuild-rds"
  policy = file("${path.module}/codebuild-rds-policy.json")
}

resource "aws_iam_policy" "codebuild_s3" {
  name   = "mercurii-codebuild-s3"
  policy = file("${path.module}/codebuild-s3-policy.json")
}

resource "aws_iam_policy" "codebuild_ecr" {
  name   = "mercurii-codebuild-ecr"
  policy = file("${path.module}/codebuild-ecr-policy.json")
}

resource "aws_iam_role" "codebuild" {
  name               = "mercurii-codebuild-role"
  assume_role_policy = file("${path.module}/codebuild-role-assume-policy.json")
  managed_policy_arns = [
    aws_iam_policy.codebuild_vpc.arn,
    aws_iam_policy.codebuild_log.arn,
    aws_iam_policy.codebuild_codecommit.arn,
    aws_iam_policy.codebuild_rds.arn,
    aws_iam_policy.codebuild_s3.arn,
    aws_iam_policy.codebuild_ecr.arn
  ]
}

#===============================================================================
# API Role
#===============================================================================

resource "aws_iam_policy" "api_rds" {
  name   = "mercurii-api-rds"
  policy = file("${path.module}/api-rds-policy.json")
}

resource "aws_iam_policy" "api_logs" {
  name   = "mercurii-api-logs"
  policy = file("${path.module}/api-logs-policy.json")
}

resource "aws_iam_policy" "api_xray" {
  name   = "mercurii-api-xray"
  policy = file("${path.module}/api-xray-policy.json")
}

resource "aws_iam_role" "api" {
  name               = "mercurii-api-role"
  assume_role_policy = file("${path.module}/api-role-assume-policy.json")
  managed_policy_arns = [
    aws_iam_policy.api_rds.arn,
    aws_iam_policy.api_logs.arn,
    aws_iam_policy.api_xray.arn,
  ]
}
