terraform {
  backend "s3" {
    bucket = "<your-bucket-name>"
    key    = "terraform.tfstate"
    region = "<hetzner-region>"
    endpoints = {
      s3 = "https://<hetzner-region>.your-objectstorage.com"
    }
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }
}
