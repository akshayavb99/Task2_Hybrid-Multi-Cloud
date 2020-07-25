variable "bkt_name" {}
variable "bkt_acl" {}
variable "img_upload_link" {}
variable "bkt_obj_acl" {}
variable "img_name" {}

resource "aws_s3_bucket" "test-html-bkt" {
  bucket = var.bkt_name
  acl    = var.bkt_acl
  tags = {
    Name = var.bkt_name
  }

  provisioner "local-exec" {
	command = "git clone ${var.img_upload_link} image"
  }

  provisioner "local-exec" {
	when = destroy
	command = "echo Y | rmdir /s image"
  }
}

resource "aws_s3_bucket_object" "test-html-obj" {

  depends_on = [aws_s3_bucket.test-html-bkt,]
  bucket = var.bkt_name
  key = var.img_name
  source = "image/${var.img_name}"
  acl = var.bkt_obj_acl
}

output "s3_bkt" {
   value = aws_s3_bucket.test-html-bkt
}

output "s3_bkt_obj" {
   value = aws_s3_bucket_object.test-html-obj
}