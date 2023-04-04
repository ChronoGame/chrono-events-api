terraform {
  required_version = "~> 1.0.4"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
    archive = {
      source = "hashicorp/archive"
    }
    
  }

  backend "s3" {
    bucket = "tjw-terraform"
    key = "chrono_events_backend/terraform.tfstate"
    region = "us-east-1"
    profile = "tylerw"
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "tylerw"
}
provider "archive" {}


