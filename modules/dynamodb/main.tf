resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.region}.dynamodb"
}

resource "aws_vpc_endpoint_route_table_association" "example" {
  route_table_id  = var.pub_rt_id
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
}

resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "Books"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "title"

  tags = {
    Name        = "dynamodb-table-1"
  }
  attribute {
    name = "title"
    type = "S"
  }
}