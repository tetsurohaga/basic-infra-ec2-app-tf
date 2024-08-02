# Provider
provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      terraform = "app1"
    }
  }
}

# Provider us-east-1
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
  default_tags {
    tags = {
      terraform = "app1"
    }
  }
}

# use for lookup myIP
provider http {
}