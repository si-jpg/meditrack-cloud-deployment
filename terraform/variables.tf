variable "aws_region" {
  type    = string
  default = "eu-west-3" # Paris
}

variable "project_name" {
  type    = string
  default = "meditrack" # préfixe des noms (vpc, bucket, etc.)
}

variable "allowed_ssh_cidr" {
  type    = string
  default = "0.0.0.0/0" # qui peut SSH ; on mettra notre ip publque 
}

variable "ec2_instance_type" {
  type    = string
  default = "t3.micro"
}
