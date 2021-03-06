output "database_password" {
  value = aws_ssm_parameter.db_password.value
  sensitive = true
}

output "database_endpoint" {
  value = module.db.db_instance_endpoint
}

output "database_instance_id" {
  value = module.db.db_instance_id
}

output "database_instance_address" {
  value = module.db.db_instance_address
}

output "database_instance_port" {
  value = module.db.db_instance_port
}