resource "random_password" "postgres-password" {
  length = 16
  special = false
}

resource "aws_security_group" "allow_postgres" {
  name        = "allow_postgres"
  description = "Allow Postgresql inbound traffic"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 5432
    protocol    = "tcp"
  }

  tags = {
  }
}

resource "aws_db_instance" "mercurii" {
  name                  = "mercurii"
  engine                = "postgres"
  engine_version        = "11"

  storage_type          = "gp2"
  allocated_storage     = 20
  max_allocated_storage = 1000

  instance_class        = "db.t3.micro"
  db_subnet_group_name  = "${module.vpc.database_subnet_group}"

  username              = "postgres"
  password              = "${random_password.postgres-password.result}"

  skip_final_snapshot   = true
}

output "db_password" {
  value = "${aws_db_instance.mercurii.password}"
}