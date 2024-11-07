variable "instance_type" {
    default = "t2.micro"
    type = string
  
}

variable "prefix" {
  default = "main"
}

variable "project" {
  default = "devops-102"
}

variable "contact" {
  default = "tgangabhavani2003@gmail.com"
}

variable "keyPath" {
  type    = string
  default = ""
}