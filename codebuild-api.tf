resource "aws_ecr_repository" "mercurii-api" {
  name                 = "mercurii-api"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_codebuild_project" "mercurii-api" {
  name           = "mercurii-api"
  description    = "REST API for Mercurii"

  source {
    type            = "CODECOMMIT"
    location        = "https://git-codecommit.us-west-1.amazonaws.com/v1/repos/mercurii-api"
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
      name  = "IMAGE_REPOSITORY_URL"
      value = "${aws_ecr_repository.mercurii-api.repository_url}"
    }

    environment_variable {
      name  = "DB_INSTANCE"
      value = "${aws_db_instance.mercurii.identifier}"
    }
  }

  tags = {
  }
}