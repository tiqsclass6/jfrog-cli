# 5. Insert Transit Gateway (TGW) Attachments to the TGW

resource "aws_ec2_transit_gateway_vpc_attachment" "VPC-A-Virginia-Prod-TGW-Attachment" {
  subnet_ids         = [aws_subnet.vpc-A-public-us-east-1a.id]
  transit_gateway_id = aws_ec2_transit_gateway.Virginia-TGW01.id
  vpc_id             = aws_vpc.VPC-A-Virginia-Prod.id

  tags = {
    Name = "VPC-A-Virginia-Prod-TGW-Attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "VPC-B-Virginia-Dev-TGW-Attachment" {
  subnet_ids         = [aws_subnet.vpc-B-private-us-east-1b.id]
  transit_gateway_id = aws_ec2_transit_gateway.Virginia-TGW01.id
  vpc_id             = aws_vpc.VPC-B-Virginia-Dev.id

  tags = {
    Name = "VPC-B-Virginia-Dev-TGW-Attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "VPC-C-Virginia-Test-TGW-Attachment" {
  subnet_ids         = [aws_subnet.vpc-C-private-us-east-1c.id]
  transit_gateway_id = aws_ec2_transit_gateway.Virginia-TGW01.id
  vpc_id             = aws_vpc.VPC-C-Virginia-Test.id

  tags = {
    Name = "VPC-C-Virginia-Test-TGW-Attachment"
  }
}