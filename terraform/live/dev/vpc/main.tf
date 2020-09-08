terraform {
  required_version = "~> 0.12"

  # The configuration for this backend will be filled in by Terragrunt
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {
  }
}

provider "aws" {
  version = "~> 2.0"
  region  = "eu-west-1"
}

