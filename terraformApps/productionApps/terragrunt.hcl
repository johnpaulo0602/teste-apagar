remote_state {
  backend = "s3"
  config = {
    bucket          = "appversion-control-production"
    key             = "terraform/${path_relative_to_include()}/terraform.tfstate"
    region          = "us-west-2"
    encrypt         = true
    dynamodb_table  = "terraform"
  }
}