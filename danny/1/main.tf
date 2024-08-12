provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./vpc"
}

module "s3" {
  source = "./s3"
  vpc_id = module.vpc.vpc_id
  private_subnet_id = module.vpc.private_subnet_id
}

module "efs" {
  source = "./efs"
  vpc_id = module.vpc.vpc_id
  private_subnet_id = module.vpc.private_subnet_id
}
