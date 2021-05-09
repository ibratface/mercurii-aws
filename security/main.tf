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

resource "aws_iam_role" "codebuild" {
  name                = "mercurii-codebuild-role"
  assume_role_policy  = file("${path.module}/codebuild-role-assume-policy.json")
  managed_policy_arns = [
    aws_iam_policy.codebuild_vpc.arn, 
    aws_iam_policy.codebuild_log.arn, 
    aws_iam_policy.codebuild_codecommit.arn,
    aws_iam_policy.codebuild_rds.arn,
    aws_iam_policy.codebuild_s3.arn
  ]
}

# resource "aws_iam_role_policy" "codebuild-mercurii" {
#   name = "codebuild-mercurii-role-policy"
#   role = aws_iam_role.codebuild-mercurii.name

#   policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "logs:*",
#         "codecommit:BatchGet*",
#         "codecommit:BatchDescribe*",
#         "codecommit:Describe*",
#         "codecommit:EvaluatePullRequestApprovalRules",
#         "codecommit:Get*",
#         "codecommit:List*",
#         "codecommit:GitPull",
#         "ec2:*",
#         "rds:CreateDBSnapshot",
#         "rds-data:ExecuteSql",
#         "rds-data:ExecuteStatement",
#         "rds-data:BatchExecuteStatement",
#         "rds-data:BeginTransaction",
#         "rds-data:CommitTransaction",
#         "rds-data:RollbackTransaction",
#         "tag:GetResources",
#         "ecr:GetAuthorizationToken",
#         "ecr:BatchCheckLayerAvailability",
#         "ecr:GetDownloadUrlForLayer",
#         "ecr:GetRepositoryPolicy",
#         "ecr:DescribeRepositories",
#         "ecr:ListImages",
#         "ecr:DescribeImages",
#         "ecr:BatchGetImage",
#         "ecr:GetLifecyclePolicy",
#         "ecr:GetLifecyclePolicyPreview",
#         "ecr:ListTagsForResource",
#         "ecr:DescribeImageScanFindings",
#         "ecr:InitiateLayerUpload",
#         "ecr:UploadLayerPart",
#         "ecr:CompleteLayerUpload",
#         "ecr:PutImage"
#       ],
#       "Resource": "*"
#     }
#   ]    
# }  
# POLICY
# }
