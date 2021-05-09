resource "aws_codebuild_project" "mercurii-migration" {
  name        = "mercurii-migration"
  description = "Performs flyway migration"

  source {
    type      = "CODECOMMIT"
    location  = "https://git-codecommit.us-west-1.amazonaws.com/v1/repos/mercurii-db"
    buildspec = file("${path.module}/buildspec.migration.yml")
  }

  service_role = var.codebuild_role_arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "DB_INSTANCE_ID"
      value = var.db_instance_id
    }

    environment_variable {
      name  = "POSTGRES_HOST"
      value = var.db_endpoint
    }

    environment_variable {
      name  = "POSTGRES_DB"
      value = var.db_name
    }

    environment_variable {
      name  = "FLYWAY_URL"
      value = "jdbc:postgresql://${var.db_endpoint}/${var.db_name}"
    }

    environment_variable {
      name  = "FLYWAY_USER"
      value = var.db_username
    }

    environment_variable {
      name  = "FLYWAY_PASSWORD"
      value = var.db_password
    }

    environment_variable {
      name  = "FLYWAY_DEFAULT_SCHEMA"
      value = var.db_default_schema
    }
  }

  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = var.database_subnets
    security_group_ids = var.security_group_ids
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = {
  }
}

resource "aws_codebuild_project" "mercurii-frontend" {
  name        = "mercurii-frontend"
  description = "Set up S3 public web server"

  source {
    type     = "CODECOMMIT"
    location = "https://git-codecommit.us-west-1.amazonaws.com/v1/repos/mercurii-frontend"
    buildspec = templatefile("${path.module}/buildspec.frontend.yml", {
      angular_cli_version = var.angular_cli_version
      s3_bucket_name = var.s3_bucket_name
    })
  }

  service_role = var.codebuild_role_arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
  }

  tags = {
  }
}

# resource "aws_ecr_repository" "mercurii-api" {
#   name                 = "mercurii-api"
#   image_tag_mutability = "MUTABLE"
#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }

# resource "aws_codebuild_project" "mercurii-api" {
#   name           = "mercurii-api"
#   description    = "REST API for Mercurii"

#   source {
#     type            = "CODECOMMIT"
#     location        = "https://git-codecommit.us-west-1.amazonaws.com/v1/repos/mercurii-api"
#   }

#   service_role  = "${aws_iam_role.codebuild-mercurii.arn}"

#   artifacts {
#     type = "NO_ARTIFACTS"
#   }

#   environment {
#     compute_type                = "BUILD_GENERAL1_SMALL"
#     image                       = "aws/codebuild/standard:3.0"
#     type                        = "LINUX_CONTAINER"
#     image_pull_credentials_type = "CODEBUILD"
#     privileged_mode             = true

#     environment_variable {
#       name  = "IMAGE_REPOSITORY_URL"
#       value = "${aws_ecr_repository.mercurii-api.repository_url}"
#     }

#     environment_variable {
#       name  = "DB_INSTANCE"
#       value = "${aws_db_instance.mercurii.identifier}"
#     }
#   }

#   tags = {
#   }
# }
