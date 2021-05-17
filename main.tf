terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.37.0"
    }
  }
  backend "s3" {
    bucket  = "terraform.mercurii.com"
    region  = "us-west-1"
    key     = "mercurii.tfstate"
    profile = "terraform"
  }
}

provider "aws" {
  profile = "terraform"
  region  = "us-west-1"

  skip_requesting_account_id = false
}

#===============================================================================
# Useful Variables
#===============================================================================

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ecr_repository" "api" {
  name = "mercurii-api"
}

locals {
  db_username       = "mercurii"
  db_default_schema = "mercurii"
  db_default_db     = "mercurii"

  db_src_url       = "https://git-codecommit.us-west-1.amazonaws.com/v1/repos/mercurii-db"
  frontend_src_url = "https://git-codecommit.us-west-1.amazonaws.com/v1/repos/mercurii-frontend"
  api_src_url      = "https://git-codecommit.us-west-1.amazonaws.com/v1/repos/mercurii-api"

  api_image_url            = "618105743745.dkr.ecr.us-west-1.amazonaws.com/mercurii-api"
  api_registry_url         = "${data.aws_ecr_repository.api.registry_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
  api_domain_name          = "api.mercur-ii.com"
  api_cors_allowed_origins = ["https://www.mercur-ii.com"]
}

#===============================================================================
# Modules
#===============================================================================

module "network" {
  source = "./network"
  env    = var.env
}

module "security" {
  source = "./security"
  env    = var.env
  vpc_id = module.network.vpc_id
}

module "db" {
  source               = "./db"
  env                  = var.env
  username             = local.db_username
  db_subnet_group_name = module.network.database_subnet_group_name
  subnet_ids           = module.network.database_subnets
  security_group_ids   = [module.security.database_security_group_id]
}

module "frontend" {
  source = "./frontend"
  env    = var.env
}

module "api" {
  source = "./api"
  env    = var.env

  role_arn  = module.security.api_role_arn
  image_uri = data.aws_ecr_repository.api.repository_url

  lambda_subnets         = module.network.private_subnets
  lambda_security_groups = [module.security.lambda_security_group_id]

  db_address = module.db.database_instance_address
  db_port     = module.db.database_instance_port
  db_username = local.db_username
  db_password = module.db.database_password
  db_name     = local.db_default_db

  api_domain_name      = local.api_domain_name
  cors_allowed_origins = local.api_cors_allowed_origins
}

module "cicd" {
  source = "./cicd"
  env    = var.env

  migration_source_location = local.db_src_url
  frontend_source_location  = local.frontend_src_url
  api_source_location       = local.api_src_url
  api_image_repository      = data.aws_ecr_repository.api.repository_url
  api_image_registry        = local.api_registry_url
  aws_region                = data.aws_region.current.name

  db_instance_id    = module.db.database_instance_id
  db_endpoint       = module.db.database_endpoint
  db_username       = local.db_username
  db_password       = module.db.database_password
  db_name           = local.db_default_db
  db_default_schema = local.db_default_schema

  vpc_id             = module.network.vpc_id
  database_subnets   = module.network.database_subnets
  security_group_ids = [module.security.codebuild_security_group_id]
  codebuild_role_arn = module.security.codebuild_role_arn

  s3_bucket_name = module.frontend.s3_bucket_name
}
