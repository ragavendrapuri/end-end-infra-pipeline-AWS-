terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

module "infra_services" {
  source            = "../modules/"
  cloud_env         = "stage"
  vpc_tag_name      = "N10135_stage_vpc"
  instance_count    = "2"
  instance_type     = "t2.micro"
  vpc_cidr          = "172.31.0.0/16"
  public_cidr       = "172.31.1.0/24"
  private_cidr      = "172.31.2.0/24"
  bucket_name       = "testing-terraform-s3-bucket-data"
  instance_key_name = "test-tf-key"
}