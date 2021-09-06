resource "aws_vpc" "nginx_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "${var.service_name}-vpc"
  }
}

locals {
  public_subnets = {
    "${var.aws_region}a" = "10.0.101.0/24"
    "${var.aws_region}b" = "10.0.102.0/24"
  }
  private_subnets = {
    "${var.aws_region}a" = "10.0.201.0/24"
    "${var.aws_region}b" = "10.0.202.0/24"
  }
}

resource "aws_subnet" "nginx_priv_subnets" {
  count = length(local.private_subnets)
  vpc_id     = aws_vpc.nginx_vpc.id
  cidr_block = element(values(local.private_subnets), count.index)
  availability_zone = element(keys(local.private_subnets), count.index)
  tags = {
    Name = "${var.service_name}-priv-sn-${count.index + 1}"
  }
}

resource "aws_subnet" "nginx_pub_subnets" {
  count = length(local.public_subnets)
  vpc_id     = aws_vpc.nginx_vpc.id
  cidr_block = element(values(local.public_subnets), count.index)
  availability_zone = element(keys(local.public_subnets), count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.service_name}-pub-sn-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.nginx_vpc.id

  tags = {
    Name = "${var.service_name}-ig"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.nginx_vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(local.public_subnets)
  subnet_id      = element(aws_subnet.nginx_pub_subnets.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

/////////////
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.nginx_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(local.private_subnets)
  subnet_id      = element(aws_subnet.nginx_priv_subnets.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "${var.service_name}-eip"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.nginx_pub_subnets[0].id

  tags = {
    Name = "${var.service_name}-nat-gw"
  }
}
