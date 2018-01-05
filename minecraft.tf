provider "aws" {
	access_key = "${var.access_key}"
	secret_key = "${var.secret_key}"
	region     = "${var.region}"
}

resource "aws_key_pair" "key" {
   key_name = "minecraft-key-pair-useast1"
   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCDLvXV/s6OcHMU5/j42rpbnYZnthXrD7VaAXd0kVRonqL8DLkBIz+FNzPHCeTMTCot6oo9V/z6VQ/xwAGt+0zfPLrv8u7d2K/XV86Pfq2Gv/ltQiqAGJo8IyDW3mRUpu3l2NcAV3awEAK/+MKF4blXYGJDXgiGxeyvuwhfd8VRnA+FHo7PzA2HI/Pj5C2RKiS/RPqMt0QUIT1qiHUf//xbDxvYeMfLGyj7aVoPAh5u/AEc700IFD+kgFQO2V6syeC3hepTvMoR/nbyAnbIv8iioEsS1wFAapqS/XVVm7VZcT+AmwMmZojlUoTpBIGh1N3Q+2e+3ArHqmiPcEZkk+SZ"
}

resource "aws_spot_instance_request" "minecraft" {
	availability_zone = "us-east-1a"
	ami = "ami-5583d42f"
	instance_type = "m5.xlarge"
	
	spot_price = "0.1"
	wait_for_fulfillment = true
	spot_type = "one-time"
	
	root_block_device {
		volume_size = "15"
		delete_on_termination=true
	}
	subnet_id = "${aws_subnet.minecraft.id}"
	vpc_security_group_ids = ["${aws_security_group.minecraft.id}"]
	
	ebs_optimized=true
	key_name="${aws_key_pair.key.key_name}"
	monitoring=true
	
	connection {
		user = "ec2-user"
		host = "${aws_spot_instance_request.minecraft.public_ip}"
		private_key = "${file("~/.ssh/administrator-key-pair-useast1.pem")}"
	}

	provisioner "file" {
		source = "setup.sh"
		destination = "/home/ec2-user/setup.sh"
	}

	provisioner "file" {
		source = "minecraft-init"
		destination = "/home/ec2-user/minecraft-init"
	}

	provisioner "remote-exec" {
		inline = ["env ACCESS_KEY=${var.access_key} SECRET_KEY=${var.secret_key} REGION=${var.region} sh /home/ec2-user/setup.sh"]
	}

	depends_on = ["aws_internet_gateway.gw"]
}

