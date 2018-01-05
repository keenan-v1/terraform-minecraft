resource "aws_eip" "ip" {
	vpc = true
	instance = "${aws_spot_instance_request.minecraft.spot_instance_id}"
	associate_with_private_ip = "${aws_spot_instance_request.minecraft.private_ip}"
	depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_security_group" "minecraft" {
	name = "minecraft"
	description = "Minecraft Server security"
	vpc_id = "${aws_vpc.minecraft.id}"
	
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		ipv6_cidr_blocks = ["::/0"]
	}

	ingress {
		from_port = 25565
		to_port = 25565
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		ipv6_cidr_blocks = ["::/0"]
	}

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
		ipv6_cidr_blocks = ["::/0"]
	}
}

resource "aws_vpc" "minecraft" {
	cidr_block="10.0.0.0/16"
}

resource "aws_internet_gateway" "gw" {
	vpc_id = "${aws_vpc.minecraft.id}"
}

resource "aws_subnet" "minecraft" {
	availability_zone="us-east-1a"
	cidr_block = "10.0.0.0/24"
	vpc_id = "${aws_vpc.minecraft.id}"
	map_public_ip_on_launch = true

depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_route_table" "r" {
	vpc_id = "${aws_vpc.minecraft.id}"
	
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.gw.id}"
	}

	route {
		ipv6_cidr_block = "::/0"
		gateway_id = "${aws_internet_gateway.gw.id}"
	}

	depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_route_table_association" "a" {
	subnet_id = "${aws_subnet.minecraft.id}"
	route_table_id = "${aws_route_table.r.id}"
}


