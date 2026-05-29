# Plugins installés par "terraform init"
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws   = { source = "hashicorp/aws", version = "~> 5.0" }   # API AWS
    tls   = { source = "hashicorp/tls", version = "~> 4.0" }   # clé SSH
    local = { source = "hashicorp/local", version = "~> 2.4" } # fichier .pem local
  }
}

data "aws_caller_identity" "current" {}

provider "aws" {
  region = var.aws_region # eu-west-3 = Paris

  default_tags {
    tags = {
      Project   = "MediTrack"
      ManagedBy = "Terraform"
    }
  }
}
