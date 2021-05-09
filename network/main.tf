module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "mercurii-${var.env}"
  cidr = "10.0.0.0/16"

  azs              = ["us-west-1b", "us-west-1c"]
  public_subnets   = ["10.0.1.0/24"]
  private_subnets  = ["10.0.21.0/24"]
  database_subnets = ["10.0.31.0/24", "10.0.32.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_nat_gateway_route      = true
  # create_database_internet_gateway_route = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
