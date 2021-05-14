#===============================================================================
# DB - Migration
#===============================================================================

resource "aws_codebuild_project" "mercurii-migration" {
  name        = "mercurii-migration"
  description = "Performs flyway migration"

  source {
    type      = "CODECOMMIT"
    location  = var.migration_source_location
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

#===============================================================================
# Frontend
#===============================================================================

resource "aws_codebuild_project" "mercurii-frontend" {
  name        = "mercurii-frontend"
  description = "Set up S3 public web server"

  source {
    type     = "CODECOMMIT"
    location = var.frontend_source_location
    buildspec = templatefile("${path.module}/buildspec.frontend.yml", {
      angular_cli_version = var.angular_cli_version
      s3_bucket_name      = var.s3_bucket_name
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

#===============================================================================
# API
#===============================================================================

resource "aws_codebuild_project" "mercurii-api" {
  name        = "mercurii-api"
  description = "REST API for Mercurii"

  source {
    type      = "CODECOMMIT"
    location  = var.api_source_location
    buildspec = file("${path.module}/buildspec.api.yml")
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
      name  = "IMAGE_REPOSITORY_URL"
      value = var.api_image_repository
    }

    environment_variable {
      name  = "ECR_REGISTRY_ID"
      value = var.api_image_registry
    }

    environment_variable {
      name  = "AWS_REGION"
      value = var.aws_region
    }
  }

  tags = {
  }
}
