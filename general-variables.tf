variable "zone" {
  type    = string
  default = "us-east-1"
}
variable "subnet" {
  type    = string
  default = "subnet"
}
variable "security_group" {
  type    = string
  default = "sg"
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "ami" {
  type    = string
  default = "ami"
}
variable "zip_files" {
  type = map(string)
  default = {
    indexer_file    = "indexer.zip"
    api_file        = "api.zip"
    zincsearch_file = "zincsearch.zip"
    data_file       = "data.zip"
  }
}