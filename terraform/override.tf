# Work around `terraform init` unexpectedly installing the latest versions.
# Maybe related with https://github.com/hashicorp/terraform/issues/32305
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.43.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "7.30.0"
    }
  }
}
