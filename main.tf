# ---------------------------
# Configure AWS Provider
# ---------------------------
provider "aws" {
  region = "us-east-1"   # AWS region where resources will be provisioned
}

# ---------------------------
# Configure Vault Provider
# ---------------------------
provider "vault" {
  address = "http://<vault-server-ip>:8200"  # Vault server address
  skip_child_token = true                    # Ensures Terraform uses parent token for auth

  # Authenticate using AppRole login
  auth_login {
    path = "auth/approle/login"              # Vault auth path (AppRole)
    parameters = {
      role_id   = "<your-role-id>"           # Role ID generated from Vault CLI
      secret_id = "<your-secret-id>"         # Secret ID generated from Vault CLI
    }
  }
}

# ---------------------------
# Fetch secret from Vault KV v2
# ---------------------------
data "vault_kv_secret_v2" "example" {
  mount = "kv"             # Secret engine mount path in Vault (default is 'kv')
  name  = "test-secret"    # Name of the secret stored in Vault
}

# ---------------------------
# Create an AWS EC2 instance
# ---------------------------
resource "aws_instance" "my_instance" {
  ami           = "ami-0a7d80731ae1b2435"   # Amazon Machine Image ID
  instance_type = "t2.micro"                # Instance type

  tags = {
    # Adding a tag with value fetched securely from Vault
    # For example, if Vault secret has key "username", it will be attached as a tag
    Secret = data.vault_kv_secret_v2.example.data["username"]
  }
}
