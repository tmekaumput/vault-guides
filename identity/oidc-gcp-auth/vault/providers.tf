provider "vault" {
  # version = ">= 1.3.1"
  address = var.VAULT_ADDRESS
  skip_tls_verify = var.VAULT_SKIP_VERIFY
  token = var.VAULT_TOKEN
}

terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.0.0"
    }
  }
}