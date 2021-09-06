output "instances_public_ip" {
  description = "Public IP address of the EC2 instances"
  value = aws_instance.app_server.*.public_ip
}