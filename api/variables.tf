variable "env" {
  type = string
}

variable "role_arn" {
  type = string
}

variable "image_uri" {
  type = string
}

variable "lambda_subnets" {
  type = list(string)
}

variable "lambda_security_groups" {
  type = list(string)
}

variable "db_address" {
  type = string
}

variable "db_port" {
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

variable "api_domain_name" {
  type = string
}

variable "cors_allowed_origins" {
  type = list(string)
}