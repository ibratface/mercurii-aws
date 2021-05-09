variable "env" {
  type = string
}

variable "db_endpoint" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_default_schema" {
  type = string
}

variable "db_instance_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "database_subnets" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "codebuild_role_arn" {
  type = string
}

variable "angular_cli_version" {
  type = string
  default = "9.1.11"
}

variable "s3_bucket_name" {
  type = string
}