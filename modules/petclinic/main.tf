resource "aws_security_group" "http_sg" {
  name        = "http_sg"
  vpc_id      = var.aws_vpc_id

  ingress {
    from_port        = 5000
    to_port          = 5000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.key.public_key_openssh

  #  provisioner "local-exec" {
  #    command = "echo '${tls_private_key.key.private_key_pem}' > ./${var.key_name}.pem"
  #  }
}

resource "local_file" "private_key" {
  content = "${tls_private_key.key.private_key_pem}"
  filename = "./${var.key_name}.pem"
  file_permission = "400"
}

//data "template_file" "test" {
//  template = <<-EOF
//   #!/bin/bash
//   echo "MYSQL_PASS=${random_password.password.result}" >> /etc/environment
//   echo "MYSQL_URL=jdbc:mysql://${aws_db_instance.default.address}:3306/${var.mysql_db_name}?allowPublicKeyRetrieval=true&useSSL=false" >> /etc/environment
//   echo "MYSQL_USER=${var.mysql_user}" >> /etc/environment
//   echo "spring_profiles_active=mysql" >> /etc/environment
//  EOF
//}


data "template_file" "test" {
  template = <<-EOF
   #!/bin/bash
   echo "ACCESS_KEY=${var.aws_access_key}" >> /etc/environment
   echo "SECRET_KEY=${var.aws_secret_key}" >> /etc/environment
   echo "REGION_NAME=${var.region}" >> /etc/environment
  EOF
}

resource "aws_instance" "app_server" {
  ami           = var.ami
  instance_type = var.instance_type
  count         = var.instances_count
  key_name      = aws_key_pair.generated_key.key_name
  user_data = base64encode(data.template_file.test.rendered)
  subnet_id = var.aws_pub_subnet.0.id
  vpc_security_group_ids = [aws_security_group.http_sg.id]
  tags = {
    Name  = "Instance-${count.index + 1}"
  }
}

//resource "random_password" "password" {
//  length           = 16
//  special          = true
//  override_special = "_%@"
//}
//
//resource "aws_db_subnet_group" "db_group" {
//  name       = "education"
//  subnet_ids = var.aws_pub_subnet.*.id
//}
//
//resource "aws_db_instance" "default" {
//  allocated_storage    = 20
//  engine               = "mysql"
//  engine_version       = "8.0.23"
//  instance_class       = "db.t2.micro"
//  name                 = var.mysql_db_name
//  username             = var.mysql_user
//  password             = random_password.password.result
//  db_subnet_group_name   = aws_db_subnet_group.db_group.name
//  skip_final_snapshot  = true
//}