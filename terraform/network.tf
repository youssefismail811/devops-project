# -------------------------------#
# VPC
# -------------------------------#
resource "aws_vpc" "mainvpc" {
  cidr_block                       = var.vpc_cidr_block
  instance_tenancy                 = "default"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name = "Main VPC"
  }
}

# -------------------------------#
# public subnet 1
# -------------------------------#
resource "aws_subnet" "Public_Subnet_1" {
  vpc_id                                = aws_vpc.mainvpc.id
  cidr_block                            = var.public_subnet_1_cidrs
  availability_zone                     = var.AZ_1
  map_public_ip_on_launch               = true
  tags = {
    Name                                = "Public Subnet 1"
    "kubernetes.io/cluster/eks-cluster" = "shared"
    "kubernetes.io/role/elb"            = "1"
  }
}

# -------------------------------#
# public subnet 2
# -------------------------------#
resource "aws_subnet" "Public_Subnet_2" {
  vpc_id                  = aws_vpc.mainvpc.id
  cidr_block              = var.public_subnet_2_cidrs
  availability_zone       = var.AZ_2
  map_public_ip_on_launch = true

  tags = {
    Name                                  = "Public Subnet 2"
    "kubernetes.io/cluster/eks-cluster"   = "shared"
    "kubernetes.io/role/elb"              = "1"
  }
}

# -------------------------------#
# private subnet 1
# -------------------------------#
resource "aws_subnet" "Private_Subnet_1" {
  vpc_id                  = aws_vpc.mainvpc.id
  cidr_block              = var.private_subnet_1_cidrs
  availability_zone       = var.AZ_1
  map_public_ip_on_launch = false

  tags = {
      Name                                = "Private Subnet 1"
      "kubernetes.io/cluster/eks-cluster" = "shared"
      "kubernetes.io/role/internal-elb"   = "1"
  }
}

# -------------------------------#
# private subnet 2
# -------------------------------#
resource "aws_subnet" "Private_Subnet_2" {
  vpc_id                  = aws_vpc.mainvpc.id
  cidr_block              = var.private_subnet_2_cidrs
  availability_zone       = var.AZ_2
  map_public_ip_on_launch = false

  tags = {
      Name                                = "Private Subnet 2"
      "kubernetes.io/cluster/eks-cluster" = "shared"
      "kubernetes.io/role/internal-elb"   = "1"
  }
}

# -------------------------------#
# internet gateway
# -------------------------------#
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.mainvpc.id

  tags = {
    Name = "Main IGW"
  }
}

# -------------------------------#
# public route table
# -------------------------------#
resource "aws_route_table" "Public_Route_Table" {
  vpc_id = aws_vpc.mainvpc.id

  route {
    cidr_block = var.cidrs
    gateway_id = aws_internet_gateway.main_igw.id
  }
  tags = {
    Name = "Public Route Table"
  }
}

# -------------------------------#
# public route table association
# -------------------------------#
resource "aws_route_table_association" "public_rt_assoc_1" {
  subnet_id      = aws_subnet.Public_Subnet_1.id
  route_table_id = aws_route_table.Public_Route_Table.id
}
resource "aws_route_table_association" "public_rt_assoc_2" {
  subnet_id      = aws_subnet.Public_Subnet_2.id
  route_table_id = aws_route_table.Public_Route_Table.id
}

# -------------------------------#
# private route table
# -------------------------------#
resource "aws_route_table" "Private_Route_Table" {
  vpc_id = aws_vpc.mainvpc.id
  
  route  {
    cidr_block     = var.cidrs
    nat_gateway_id = aws_nat_gateway.NAT_Gateway.id
  }
  
  tags = {
    Name = "Private Route Table"
  }
}

# -------------------------------#
# private route table association
# -------------------------------#
resource "aws_route_table_association" "private_rt_assoc_1" {
  subnet_id      = aws_subnet.Private_Subnet_1.id
  route_table_id = aws_route_table.Private_Route_Table.id
}
resource "aws_route_table_association" "private_rt_assoc_2" {
  subnet_id      = aws_subnet.Private_Subnet_2.id
  route_table_id = aws_route_table.Private_Route_Table.id
}

# -------------------------------#
# NAT Gateway
# -------------------------------#
resource "aws_eip" "NAT_EIP" {
  domain     = "vpc"
  depends_on = [ aws_internet_gateway.main_igw ]
  tags = {
    Name = "NAT EIP"
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_nat_gateway" "NAT_Gateway" {
  allocation_id = aws_eip.NAT_EIP.id
  subnet_id     = aws_subnet.Public_Subnet_1.id

  tags = {
    Name = "NAT Gateway"
  }
  depends_on = [ aws_internet_gateway.main_igw ]
}

# -------------------------------#