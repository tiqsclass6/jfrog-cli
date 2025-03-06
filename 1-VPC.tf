# 1. Setup the three (3) Virtual Private Clouds (VPC)

resource "aws_vpc" "VPC-A-Virginia-Prod" {
  cidr_block = "10.230.0.0/16"

  tags = {
    Name     = "VPC-A-Virginia-Prod"
    Service  = "VPC"
    Location = "Virginia"
    Owner    = "TIQS"
  }
}

resource "aws_vpc" "VPC-B-Virginia-Dev" {
  cidr_block = "10.231.0.0/16"

  tags = {
    Name     = "VPC-B-Virginia-Dev"
    Service  = "VPC"
    Location = "Virginia"
    Owner    = "TIQS"
  }
}

resource "aws_vpc" "VPC-C-Virginia-Test" {
  cidr_block = "10.232.0.0/16"

  tags = {
    Name     = "VPC-C-Virginia-Test"
    Service  = "VPC"
    Location = "Virginia"
    Owner    = "TIQS"
  }
}