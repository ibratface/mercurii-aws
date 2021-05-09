variable "env" {
  type = string
}

variable "username" {
  type = string
}

variable "db_subnet_group_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
  default = []
}