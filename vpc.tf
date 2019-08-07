resource "aws_vpc" "myvpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    "Name" = "myvpc"
  }
}

resource "aws_subnet" "myvpc-az-a" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "myvpc-az-a"
  }
}
