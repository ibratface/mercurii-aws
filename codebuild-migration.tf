resource "aws_ecr_repository" "mercurii-migration" {
  name                 = "mercurii-migration"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_codebuild_project" "mercurii-migration" {
  name           = "mercurii-migration"
  description    = "Builds the flyway migration image"

  source {
    type            = "CODECOMMIT"
    location        = "https://git-codecommit.us-west-1.amazonaws.com/v1/repos/mercurii-api"
    buildspec       = "buildspec-migration.yml"
  }

  service_role  = "${aws_iam_role.codebuild-mercurii.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"    
    privileged_mode             = true

    environment_variable {
      name  = "DB_INSTANCE"
      value = "${aws_db_instance.mercurii.identifier}"
    }

    environment_variable {
      name  = "MIGRATION_IMAGE_REPOSITORY_URL"
      value = "${aws_ecr_repository.mercurii-migration.repository_url}"
    }
  }

  tags = {
  }
}

resource "aws_codebuild_project" "mercurii-migration-run" {
  name           = "mercurii-migration-run"
  description    = "Runs the flyway migration image"

  source {
    type            = "NO_SOURCE"
    buildspec       =<<BUILDSPEC
version: 0.2

phases:
  pre_build:
    commands:
      # login to ecr
      - $(aws ecr get-login --region $AWS_DEFAULT_REGION --no-include-email)
      
  build:
    commands:
      # run flyway for db migration
      - flyway migrate -locations=sql
BUILDSPEC
  }

  service_role  = "${aws_iam_role.codebuild-mercurii.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "${aws_ecr_repository.mercurii-migration.repository_url}:latest"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
#    privileged_mode             = true

    environment_variable {
      name  = "FLYWAY_URL"
      value = "jdbc:postgresql://${aws_db_instance.mercurii.endpoint}/mercurii"
    }

    environment_variable {
      name  = "FLYWAY_USER"
      value = "${aws_db_instance.mercurii.username}"
    }

    environment_variable {
      name  = "FLYWAY_PASSWORD"
      value = "${aws_db_instance.mercurii.password}"
    }

    environment_variable {
      name  = "FLYWAY_DEFAULT_SCHEMA"
      value = "mercurii"
    }
  }

  vpc_config {
    vpc_id = "${module.vpc.vpc_id}"
    subnets = "${module.vpc.database_subnets}"
    security_group_ids = [
      "${aws_security_group.allow_postgres.id}",
    ]
  }

  tags = {
  }
}