data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_filter.ami]
  }

  filter {
    name   = "virtualization-type"
    values = [var.ami_filter.virtualization_type]
  }

  owners = [var.ami_filter.owner]
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.environment}-vpc"
  cidr = "${var.vpc.cidr_prefix}.0.0/16"

  azs             = ["${var.vpc.azs_prefix}a", "${var.vpc.azs_prefix}b", "${var.vpc.azs_prefix}c"]
  public_subnets  = ["${var.vpc.cidr_prefix}.101.0/24", "${var.vpc.cidr_prefix}.102.0/24", "${var.vpc.cidr_prefix}.103.0/24"]

  tags = {
    Terraform   = "true"
    Environment = "var.environment"
  }
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.2"
  name    = "${var.environment}-asg"

  min_size            = var.asg.min
  max_size            = var.asg.max
  vpc_zone_identifier = module.vpc.public_subnets
  target_group_arns   = module.alb.target_group_arns
  security_groups     = [module.security_group.security_group_id]
  instance_type       = var.instance_type
  image_id            = data.aws_ami.app_ami.id
}

module "alb" {
  source             = "terraform-aws-modules/alb/aws"
  version            = "~> 6.0"
  name               = "${var.environment}-alb"
  load_balancer_type = "application"

  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [module.security_group.security_group_id]

  target_groups = [
    {
      name_prefix      = "blog-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "var.environment"
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name    = "${var.environment}-sg"
  vpc_id  = module.vpc.vpc_id

  ingress_rules       = ["https-443-tcp","http-80-tcp","ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]

  tags = {
  Environment = "var.environment"
  }
}


