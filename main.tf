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
}

module "network" {
  source = "./network"
  env    = var.env
}

module "security" {
  source = "./security"
  env    = var.env
  vpc_id = module.network.vpc_id
}

locals {
  database_username       = "mercurii"
  database_default_schema = "mercurii"
}

module "db" {
  source               = "./db"
  env                  = var.env
  username             = local.database_username
  db_subnet_group_name = module.network.database_subnet_group_name
  subnet_ids           = module.network.database_subnets
  security_group_ids   = [module.security.database_security_group_id]
}

module "frontend" {
  source = "./frontend"
  env    = var.env
}

module "cicd" {
  source             = "./cicd"
  env                = var.env
  
  db_instance_id     = module.db.database_instance_id
  db_endpoint        = module.db.database_endpoint
  db_username        = local.database_username
  db_password        = module.db.database_password
  db_name            = "mercury"
  db_default_schema  = local.database_default_schema
  
  vpc_id             = module.network.vpc_id
  database_subnets   = module.network.database_subnets
  security_group_ids = [module.security.codebuild_security_group_id]
  codebuild_role_arn = module.security.codebuild_role_arn

  s3_bucket_name = module.frontend.s3_bucket_name
}
