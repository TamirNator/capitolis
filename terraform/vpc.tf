module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.17.0"

  name       = "cinema-vpc"
  cidr       = var.vpc_cidr
  azs        = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.0.0/26", "10.0.0.64/26"]
  #private_subnets = ["10.0.0.128/26", "10.0.0.192/26"]
  enable_nat_gateway  = false
  map_public_ip_on_launch = true
}
