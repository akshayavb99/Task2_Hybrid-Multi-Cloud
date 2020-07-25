variable "efs_token" {}

variable "encrypt" {}

variable "ec2_sg" {}

variable "ec2_subnet_id" {}

variable "ec2_public_ip" {}

resource "aws_efs_file_system" "test_efs" {
  creation_token = var.efs_token
  encrypted = var.encrypt
  tags = {
    Name = "test_efs"
  }
}

resource "aws_efs_mount_target" "test_efs_mount" {
 depends_on = [
  var.ec2_sg,
  aws_efs_file_system.test_efs,
   ]
 
    file_system_id  = aws_efs_file_system.test_efs.id
   subnet_id       = var.ec2_subnet_id
    security_groups = [var.ec2_sg.id]
 
 
   connection {
      type     = "ssh"
      user     = "ec2-user"
     private_key = file("D:/Online Courses/Hybrid Multi Cloud Computing/task2 files/mykey123.pem")
      host     = var.ec2_public_ip
   }

   provisioner "remote-exec" {
      inline = [
         "sudo mount ${aws_efs_file_system.test_efs.id}:/ /var/www/html",
          "sudo echo '${aws_efs_file_system.test_efs.id}:/ /var/www/html efs defaults,_netdev 0 0' >> /etc/fstab",
         "sudo git clone https://github.com/akshayavb99/Task1_Hybrid_Cloud.git /var/www/html/",
      ]
   }
}