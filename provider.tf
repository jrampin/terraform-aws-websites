provider "aws" {
  alias  = "acm"
  region = "us-east-1"
}

provider "aws" {
  region = var.aws_region
}
