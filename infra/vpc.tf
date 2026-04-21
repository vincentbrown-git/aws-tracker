terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "aws-tracker-vpc"
    Project = "aws-tracker"
  }
}

resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "tracker-public-1a"
    Type    = "public"
    Project = "aws-tracker"
  }
}

resource "aws_subnet" "public_1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name    = "tracker-public-1b"
    Type    = "public"
    Project = "aws-tracker"
  }
}

resource "aws_subnet" "app_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name    = "tracker-app-1a"
    Type    = "private"
    Project = "aws-tracker"
  }
}

resource "aws_subnet" "app_1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name    = "tracker-app-1b"
    Type    = "private"
    Project = "aws-tracker"
  }
}

resource "aws_subnet" "db_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name    = "tracker-db-1a"
    Type    = "isolated"
    Project = "aws-tracker"
  }
}

resource "aws_subnet" "db_1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.6.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name    = "tracker-db-1b"
    Type    = "isolated"
    Project = "aws-tracker"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "tracker-igw"
    Project = "aws-tracker"
  }
}

resource "aws_eip" "nat_1a" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name    = "tracker-nat-eip-1a"
    Project = "aws-tracker"
  }
}

resource "aws_eip" "nat_1b" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name    = "tracker-nat-eip-1b"
    Project = "aws-tracker"
  }
}

resource "aws_nat_gateway" "nat_1a" {
  allocation_id = aws_eip.nat_1a.id
  subnet_id     = aws_subnet.public_1a.id
  depends_on    = [aws_internet_gateway.main]

  tags = {
    Name    = "tracker-nat-1a"
    Project = "aws-tracker"
  }
}

resource "aws_nat_gateway" "nat_1b" {
  allocation_id = aws_eip.nat_1b.id
  subnet_id     = aws_subnet.public_1b.id
  depends_on    = [aws_internet_gateway.main]

  tags = {
    Name    = "tracker-nat-1b"
    Project = "aws-tracker"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "tracker-public-rt"
    Project = "aws-tracker"
  }
}

resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1b" {
  subnet_id      = aws_subnet.public_1b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "app_1a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1a.id
  }

  tags = {
    Name    = "tracker-app-rt-1a"
    Project = "aws-tracker"
  }
}

resource "aws_route_table" "app_1b" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1b.id
  }

  tags = {
    Name    = "tracker-app-rt-1b"
    Project = "aws-tracker"
  }
}

resource "aws_route_table_association" "app_1a" {
  subnet_id      = aws_subnet.app_1a.id
  route_table_id = aws_route_table.app_1a.id
}

resource "aws_route_table_association" "app_1b" {
  subnet_id      = aws_subnet.app_1b.id
  route_table_id = aws_route_table.app_1b.id
}

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "tracker-db-rt"
    Project = "aws-tracker"
  }
}

resource "aws_route_table_association" "db_1a" {
  subnet_id      = aws_subnet.db_1a.id
  route_table_id = aws_route_table.db.id
}

resource "aws_route_table_association" "db_1b" {
  subnet_id      = aws_subnet.db_1b.id
  route_table_id = aws_route_table.db.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public_1a.id, aws_subnet.public_1b.id]
}

output "app_subnet_ids" {
  value = [aws_subnet.app_1a.id, aws_subnet.app_1b.id]
}

output "db_subnet_ids" {
  value = [aws_subnet.db_1a.id, aws_subnet.db_1b.id]
}
