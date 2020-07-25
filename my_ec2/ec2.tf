variable "my_ec2_ami" {}

variable "my_ec2_type" {}

variable "my_ec2_key" {}

variable "my_ec2_az" {}

module "sg_module" {
  source = "D:/Online Courses/Hybrid Multi Cloud Computing/task2 files/my_sg"
  sg_name = "task2_sg"
}

resource "aws_instance" "test_terra" {
  depends_on = [module.sg_module.task2_sg,]
  ami           = var.my_ec2_ami
  instance_type =  var.my_ec2_type
  availability_zone = var.my_ec2_az
  key_name = var.my_ec2_key
  security_groups = [module.sg_module.task2_sg.name,]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("D:/Online Courses/Hybrid Multi Cloud Computing/task2 files/mykey123.pem")
    host     = aws_instance.test_terra.public_ip
    }
  provisioner "remote-exec" {
    inline = [
    "sudo yum install httpd git -y",
    "sudo systemctl restart httpd",
    "sudo systemctl enable httpd",
    ]
   }

  tags = {
     Name = "test_terra"
  }
}

output "inst_public_ip" {
   value = aws_instance.test_terra.public_ip
}

output "inst_subnet_id" {
   value = aws_instance.test_terra.subnet_id
}

output "inst_sg" {
   value = module.sg_module.task2_sg
}