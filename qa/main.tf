module "qa" {
  source = "../modules/blog"


  environment = {
    name = "qa"
  }

  vpc = {
    cidr_prefix = "10.1"
    azs_prefix = "us-east-1"
  }

  asg = {
    min = 1
    max = 1
  }


}