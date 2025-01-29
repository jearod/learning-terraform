data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "blog_vpc_dev"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]


  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "8.0.1"
  
  name                 = "blog"
  
  min_size             = 1
  max_size             = 2
  vpc_zone_identifier  = module.vpc.public_subnets
  security_groups      = [module.security_group.security_group_id]
  instance_type        = var.instance_type
  image_id             = data.aws_ami.app_ami.id  
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.13"

  name               = "blog-alb"
  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [module.security_group.security_group_id]

  target_groups = {
    blog_tg = {
      name_prefix      = "blog-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      default_action = {
        type             = "forward"
        target_group_key = "blog_tg"
      }
    }
  }

  tags = {
    Environment = "dev"
  }
}

# resource "aws_instance" "blog" {
#   ami                    = data.aws_ami.app_ami.id
#   instance_type          = var.instance_type
#   subnet_id              = module.vpc.public_subnets[0]
#   vpc_security_group_ids = [module.security_group.security_group_id]

#   tags = {
#     Name = "HelloWorld"
#   }
# }

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name    = "blog-sg"
  vpc_id  = module.vpc.vpc_id

  ingress_rules       = ["https-443-tcp","http-80-tcp","ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}


