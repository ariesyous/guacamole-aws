
# aws endpoint provider

provider "aws" {

  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "eu-west-1"
}