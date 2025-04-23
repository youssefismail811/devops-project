terraform {
  backend "s3" {
    bucket         = "devops-terraform-state-646304591001"
    key            = "env/dev/terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
