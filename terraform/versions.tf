
terraform {
  required_version = ">= 1.1"
  required_providers {
    aws = {
      version = ">= 3.0.0, < 6.0.0"
      source  = "hashicorp/aws"
    }
    template = {
      version = "~> 2.2"
      source  = "hashicorp/template"
    }
  }
}
