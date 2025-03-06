# 3. Build the Route Tables. One Public and Three Private

resource "aws_route_table" "VPC-A-Virginia-Prod-PublicRT" {
  vpc_id = aws_vpc.VPC-A-Virginia-Prod.id

  route {
    cidr_block         = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.Virginia-TGW01.id
  }

  tags = {
    Name = "VPC-A-Virginia-Prod-PublicRT"
  }
}

resource "aws_route_table" "VPC-A-Virginia-Prod-PrivateRT" {
  vpc_id = aws_vpc.VPC-A-Virginia-Prod.id

  tags = {
    Name = "VPC-A-Virginia-Prod-PrivateRT"
  }
}

resource "aws_route_table" "VPC-B-Virginia-Dev-PrivateRT" {
  vpc_id = aws_vpc.VPC-B-Virginia-Dev.id

  route {
    cidr_block         = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.Virginia-TGW01.id
  }

  tags = {
    Name = "VPC-B-Virginia-Dev-PrivateRT"
  }
}

resource "aws_route_table" "VPC-C-Virginia-Test-PrivateRT" {
  vpc_id = aws_vpc.VPC-C-Virginia-Test.id

  tags = {
    Name = "VPC-C-Virginia-Test-PrivateRT"
  }
}