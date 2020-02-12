resource "aws_iam_role" "ecs-task-execution" {
  name                = "ecs-task-execution"
  assume_role_policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs-execution" {
  name    = "ecs-execution"
  role    = "${aws_iam_role.ecs-task-execution.id}"  
  policy  = "${file("policies/ecs-task-execution-role.json")}"
}

resource "aws_ecs_cluster" "mercurii" {
  name                = "mercurii"
  capacity_providers  = ["FARGATE"]
}

# -----------------------------------------------------------------------------

resource "aws_ecs_task_definition" "mercurii-api" {
  family                    = "mercurii-api"
  container_definitions     = <<JSON
[
  {
    "name": "mercurii-api",
    "image": "${aws_ecr_repository.mercurii-api.repository_url}/api"
  }
]
JSON
  requires_compatibilities  = ["FARGATE"]
  network_mode              = "awsvpc"
  cpu                       = 256
  memory                    = 512
  execution_role_arn        = "${aws_iam_role.ecs-task-execution.arn}"
}

resource "aws_ecs_service" "mercurii-api" {
  name            = "mercurii-api"
  cluster         = "${aws_ecs_cluster.mercurii.id}"
  task_definition = "${aws_ecs_task_definition.mercurii-api.arn}"

  platform_version = "LATEST"

  desired_count   = 1
  deployment_controller {
    type = "ECS"
  }
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent = 200

  launch_type = "FARGATE"

  network_configuration {
    subnets = "${module.vpc.private_subnets}"
    security_groups = []
    assign_public_ip = false
  }
}

resource "aws_ecs_task_definition" "mercurii-migration" {
  family                    = "mercurii-migration"
  container_definitions     = <<JSON
[
  {
    "name": "mercurii-migration",
    "image": "${aws_ecr_repository.mercurii-migration.repository_url}/api"
  }
]
JSON
  requires_compatibilities  = ["FARGATE"]
  network_mode              = "awsvpc"
  cpu                       = 256
  memory                    = 512
  execution_role_arn        = "${aws_iam_role.ecs-task-execution.arn}"
}

resource "aws_ecs_service" "mercurii-api" {
  name            = "mercurii-api"
  cluster         = "${aws_ecs_cluster.mercurii.id}"
  task_definition = "${aws_ecs_task_definition.mercurii-migration.arn}"

  platform_version = "LATEST"

  desired_count   = 0
  deployment_controller {
    type = "ECS"
  }
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent = 100

  launch_type = "FARGATE"

  network_configuration {
    subnets = "${module.vpc.private_subnets}"
    security_groups = []
    assign_public_ip = false
  }
}