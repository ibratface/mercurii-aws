resource "random_password" "password" {
  length  = 16
  special = false
}
# random_password.postgres-password.result

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = ">= 3.0.0"

  identifier           = "mercurii-${var.env}"
  # name                 = "mercurii${var.env}"
  engine               = "postgres"
  engine_version       = "11"
  family               = "postgres11" # DB parameter group
  major_engine_version = "11"         # DB option group  

  instance_class        = "db.t3.micro"
  port                  = 5432
  storage_type          = "gp2"
  allocated_storage     = 20
  max_allocated_storage = 1000
  storage_encrypted     = true

  db_subnet_group_name = var.db_subnet_group_name
  publicly_accessible = true

  username = var.username
  password = random_password.password.result

  multi_az               = false
  subnet_ids             = var.subnet_ids
  vpc_security_group_ids = var.security_group_ids

  maintenance_window = "Sun:00:00-Sun:03:00"
  backup_window      = "03:00-06:00"
  # enabled_cloudwatch_logs_exports = []

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/mercurii/${var.env}/database/password/master"
  description = "Mercurii database master password"
  type        = "SecureString"
  value       = random_password.password.result

  tags = {
    environment = var.env
  }
}
