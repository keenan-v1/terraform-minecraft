variable "access_key" {}
variable "secret_key" {}
variable "region" {
	default = "us-east-1"
}
variable "amis" {
	type = "map"
	default = {
		"us-east-1" = "ami-5583d42f"
	}
}

output "ip" {
   value = "${aws_eip.ip.public_ip}"
}

variable "public_key_file" {}
variable "private_key_file" {}
