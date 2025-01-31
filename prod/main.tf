module "prod" {
  source = "../modules/blog"


  environment = "prod"

  vpc = {
    cidr_prefix = "10.2"
    azs_prefix = "us-east-1"
  }

  asg = {
    min = 1
    max = 10
  }


}