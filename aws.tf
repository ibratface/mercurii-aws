terraform {
  backend "s3" {
    bucket = "terraform.mercurii.com"
    region = "us-west-1"
    key    = "mercurii.tfstate"
  }
}

provider "aws" {
  profile = "default"
  region  = "us-west-1"
}

data "aws_region" "current" {
  
}