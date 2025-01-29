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

# data "aws_vpc" "default" {
#   default = true
# }

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

# data "aws_subnet" "default" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.default.id]
#   }

#   filter {
#     name   = "default-for-az"
#     values = ["true"]
#   }
  
#   filter {
#     name   = "availability-zone"
#     values = ["us-east-1a"] # Specify the AZ you want to use
#   }
# }

resource "aws_instance" "blog" {
  ami                    = data.aws_ami.app_ami.id
  instance_type          = var.instance_type
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.security_group.security_group_id]

  tags = {
    Name = "HelloWorld"
  }
}

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


# resource "aws_security_group" "blog" {
#   name       = "blog-sg"

#   tags = {
#     Name = "blog-sg"
#   }

#   vpc_id = data.aws_vpc.default.id
# }

# resource "aws_security_group_rule" "blog_http_in" {
#   type              = "ingress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]  
#   security_group_id = aws_security_group.blog.id
# }

# resource "aws_security_group_rule" "blog_https_in" {
#   type              = "ingress"
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   cidr_blocks       =  ["0.0.0.0/0"]  
#   security_group_id = aws_security_group.blog.id
# }

# resource "aws_security_group_rule" "blog_ssh_in" {
#   type              = "ingress"
#   from_port         = 22
#   to_port           = 22
#   protocol          = "tcp"
#   cidr_blocks       =  ["0.0.0.0/0"]  
#   security_group_id = aws_security_group.blog.id
# }

# resource "aws_security_group_rule" "blog_everything_out" {
#   type              = "egress"
#   from_port         = 0
#   to_port           = 0
#   protocol          = "-1"
#   cidr_blocks       = ["0.0.0.0/0"]  
#   security_group_id = aws_security_group.blog.id
# }