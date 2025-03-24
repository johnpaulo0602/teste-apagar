terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.56"
    }
    helm = {
       source = "hashicorp/helm"
       version = ">= 2.15.0"
    }
    kubernetes = {
       source = "hashicorp/kubernetes"
       version = ">= 2.32.0"
    }
  }
}
provider "kubernetes" {
    config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "aws" {
  region = "us-west-2"
}

# provider "cloudflare" {
#   api_token = "4z-fNf5VxAqZ1D4kbSgHW0eXz0nOr_DlH5tSKK"
# }

provider "cloudflare" {
  api_token = "4z-fNf5VxAqZ1D4kbSgHW0eXz0nOr_DlH5tSKK4a"
}