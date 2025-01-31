variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default     = "t3.nano"
}

variable "ami_filter" {
  description = "values to filter the ami"

  type = object({
    ami                 = string
    virtualization_type = string
    owner               = string
  })

  default = {
    ami                 = "bitnami-tomcat-*-x86_64-hvm-ebs-nami"
    virtualization_type = "hvm"
    owner               = "979382823631"
  }
}

variable "environment" {
  description = "Environment to deploy the resources"
  type        = string
  default     = "dev"
}

variable "vpc" {
  description = "VPC configuration"

  type = object({
    cidr_prefix = string
    azs_prefix  = string
  })

  default = {
    cidr_prefix = "10.0"
    azs_prefix  = "us-east-1"
  }
}

variable "asg" {
  description = "Autoscaling group parameters"
  
  default = {
    min = 1
    max = 2
  }
}