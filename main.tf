provider "aws" {
  region     = "ap-south-1"
  profile    = "iam_akshaya"
}

module "ec2_module" {
  source = "./my_ec2"
  my_ec2_type = "t2.micro"
  my_ec2_ami = "ami-0732b62d310b80e97" # AMI for Amazon Linux 2 AMI (HVM), SSD Volume Type (64 bit x86)
  my_ec2_key = "mykey123"
  my_ec2_az = "ap-south-1a"
}

module "s3_module" {
   source = "D:/Online Courses/Hybrid Multi Cloud Computing/task2 files/my_s3"
   bkt_name = "task2-html-bkt"
   bkt_acl = "private"
   img_upload_link = "https://github.com/akshayavb99/Task1_Hybrid_Cloud"
   bkt_obj_acl = "public-read"
   img_name = "Brihadeeswarar_Temple_full.jpg"
}

module "cloud_formation" {
   source = "./my_cf"
   s3_bkt_domain_name = module.s3_module.s3_bkt.bucket_regional_domain_name
   s3_bkt_id = module.s3_module.s3_bkt.id
   ec2_subnet = module.ec2_module.inst_subnet_id
}



module "efs_module" {
  source = "./my_efs"
  efs_token = "test_efs"
  encrypt = "true"
  ec2_sg = module.ec2_module.inst_sg
  ec2_subnet_id = module.ec2_module.inst_subnet_id
  ec2_public_ip = module.ec2_module.inst_public_ip
}

output "cf_domain_name" {
   value = "CloudFront domain name is ${module.cloud_formation.cf_domain_name}"
}

resource "null_resource" "launch_site" {
connection {
  type = "ssh"
  user = "ec2-user"
  host = module.ec2_module.inst_public_ip
  port = 22
  private_key = file("D:/Online Courses/Hybrid Multi Cloud Computing/task2 files/mykey123.pem")
  }
provisioner "remote-exec" {
 inline = ["sudo su <<EOF",
    "echo \"<img src = 'http://${module.cloud_formation.cf_domain_name}/${module.s3_module.s3_bkt_obj.key}' width='100%' height='100%'>\" >> /var/www/html/index.html",
                  "EOF",
                  "sudo systemctl restart httpd"]
}
provisioner "local-exec" {
  command = "start chrome ${module.ec2_module.inst_public_ip}"
 }
}