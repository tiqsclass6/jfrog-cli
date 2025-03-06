# 4. Build the Transit Gateway

resource "aws_ec2_transit_gateway" "Virginia-TGW01" {
  description = "Virginia-TGW01"

  tags = {
    Name     = "Virginia-TGW01"
    Service  = "TGW"
    Location = "Virginia"
    Owner    = "TIQS"
  }
}