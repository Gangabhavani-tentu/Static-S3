provider "aws" {
    region = "ap-south-1"
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
    
  }
}