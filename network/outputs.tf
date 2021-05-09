output "database_subnet_group_name" {
  value = module.vpc.database_subnet_group_name
}

output "database_subnets" {
  value = module.vpc.database_subnets
}

output "vpc_id" {
  value = module.vpc.vpc_id
}