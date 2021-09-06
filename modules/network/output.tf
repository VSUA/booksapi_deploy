output "aws_vpc_id" {
  value = aws_vpc.nginx_vpc.id
}

output "aws_priv_subnet" {
  value = aws_subnet.nginx_priv_subnets.*
}

output "aws_pub_subnet" {
  value = aws_subnet.nginx_pub_subnets.*
}

output "aws_priv_rt_id" {
  value = aws_route_table.private.id
}

output "aws_pub_rt_id" {
  value = aws_route_table.public.id
}
