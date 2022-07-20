variable "region" {
  type    = string
  default = "us-east-1"
}


variable "name_prefix" {
  type    = string
  default = "test_logic_monitor"
}

variable "volume_size" {
  type    = number
  default = 20
}

variable "desired_capacity" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 1
}

variable "min_size" {
  type    = number
  default = 1
}

variable "role_name" {
  type    = string
  default = "lmrole"
}


variable "policy_name" {
  type    = string
  default = "lmpolicy"
}

variable "policy_description" {
  type    = string
  default = "Policy for logic monitor"
}

variable "key_deletion_window" {
  type    = string
  default = "10"
}

variable "alias_name_key" {
  type    = string
  default = "logicmonitor"
}

variable "vpc_id" {
  type    = string
  default = "vpc-b62424cd"
}

variable "ami_id" {
  type    = string
  default = "ami-052efd3df9dad4825"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "security_group_name" {
  type    = string
  default = "lm-security-group"
}
