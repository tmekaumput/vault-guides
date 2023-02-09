data "vault_policy_document" "dev" {
  rule {
    path         = "secret/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow all on secrets"
  }
}

resource "vault_policy" "dev" {
  name = "dev"
  policy = data.vault_policy_document.dev.hcl
}

data "vault_policy_document" "prod" {
  rule {
    path         = "secret/*"
    capabilities = ["read", "list"]
    description  = "allow only read and list on secrets"
  }
}

resource "vault_policy" "prod" {
  name = "prod"
  policy = data.vault_policy_document.prod.hcl
}

resource "vault_jwt_auth_backend" "oidc" {
    description         = "Demonstration of the GCP OIDC auth backend"
    path                = "oidc"
    type                = "oidc"
    oidc_discovery_url  = "https://accounts.google.com"
    oidc_client_id      = var.GCP_CLIENT_ID
    oidc_client_secret  = var.GCP_CLIENT_SECRET
    # bound_issuer        = "https://myco.auth0.com/"
    provider_config = {
        provider = "gsuite"
        gsuite_service_account = var.GCP_CREDENTIAL_FILE
        gsuite_admin_impersonate = var.GCP_ADMIN_IMPERSONATE_EMAIL
        fetch_groups = false
        fetch_user_info = false
        groups_recurse_max_depth = 5
        user_custom_schemas = "Education,Preferences"
    }
}

resource "vault_jwt_auth_backend_role" "oidc" {
  backend         = vault_jwt_auth_backend.oidc.path
  role_name       = "test-role"
  token_policies  = ["default", "dev", "prod"]
  user_claim="sub"
  groups_claim="groups"
  role_type             = "oidc"
  allowed_redirect_uris = ["http://localhost:8200/ui/vault/auth/oidc/oidc/callback"]
}
