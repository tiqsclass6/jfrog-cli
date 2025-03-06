# 8. Create EC2 Instances

resource "aws_instance" "VPC-A-Virginia-Prod-Windows" {
  ami                    = "ami-05b10e08d247fb927"
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.vpc-A-public-us-east-1a.id
  vpc_security_group_ids = [aws_security_group.VPC-A-Virginia-Prod-With-Bastion-01.id]

  tags = {
    Name    = "VPC-A-Virginia-Prod-Windows"
    service = "windows"
  }
}

resource "aws_instance" "VPC-B-Virginia-Dev-basiclinux" {
  ami                    = "ami-05b10e08d247fb927"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.vpc-A-public-us-east-1a.id
  vpc_security_group_ids = [aws_security_group.VPC-A-Virginia-Prod-With-Bastion-01.id]

  tags = {
    Name    = "VPC-B-Virginia-Dev-basiclinux"
    service = "basiclinux"
  }
}
