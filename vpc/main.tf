############################################################
# VPC 
############################################################
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_support   = "${var.enable_dns_support}" 
  enable_dns_hostnames = "${var.enable_dns_hostnames}" 

  tags { Name = "${var.name}" }
}

############################################################
# Public Subnets
############################################################
resource "aws_subnet" "public_availability_zone1" {
	vpc_id            = "${aws_vpc.vpc.id}"
	cidr_block        = "${var.public_availability_zone1_cidr_block}"
	availability_zone = "${var.availability_zone1}"

  tags { Name = "${var.name} Public Availability Zone 1" }
}

resource "aws_subnet" "public_availability_zone2" {
	vpc_id            = "${aws_vpc.vpc.id}"
	cidr_block        = "${var.public_availability_zone2_cidr_block}"
	availability_zone = "${var.availability_zone2}"
  
  tags { Name = "${var.name} Public Availability Zone 2" }

}

############################################################ 
# Private Subnets
############################################################
resource "aws_subnet" "private_availability_zone1" {
  vpc_id            = "${aws_vpc.vpc.id}"
	cidr_block        = "${var.private_availability_zone1_cidr_block}"
  availability_zone = "${var.availability_zone1}"

  tags { Name = "${var.name} Private Availability Zone 1" }
}

resource "aws_subnet" "private_availability_zone2" {
  vpc_id            = "${aws_vpc.vpc.id}"
	cidr_block        = "${var.private_availability_zone2_cidr_block}"
  availability_zone = "${var.availability_zone2}"

  tags { Name = "${var.name} Private Availability Zone 1" }
}

############################################################
# EIP
############################################################
resource "aws_eip" "nat" {
  vpc = true
}

############################################################
# Routing table for public subnets
############################################################
resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags { Name = "${var.name} Internet Gateway" }
}

resource "aws_default_route_table" "default" {
  default_route_table_id = "${aws_vpc.vpc.default_route_table_id}"


  tags { Name = "${var.name} Public Default Route Table" }
}

resource "aws_route" "public" {
	route_table_id         = "${aws_vpc.vpc.default_route_table_id}"
	destination_cidr_block = "0.0.0.0/0"
	gateway_id             = "${aws_internet_gateway.ig.id}"
}

resource "aws_route_table_association" "public1" {
	subnet_id      = "${aws_subnet.public_availability_zone1.id}"
	route_table_id = "${aws_vpc.vpc.default_route_table_id}"
}

resource "aws_route_table_association" "public2" {
	subnet_id      = "${aws_subnet.public_availability_zone2.id}"
	route_table_id = "${aws_vpc.vpc.default_route_table_id}"
}

############################################################
# Routing table for private subnets
############################################################
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public_availability_zone1.id}"
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags { Name = "${var.name} Private Route Table" }
}

resource "aws_route" "private" {
	route_table_id         = "${aws_route_table.private.id}"
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}

resource "aws_route_table_association" "private1" {
	subnet_id      = "${aws_subnet.private_availability_zone1.id}"
	route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private2" {
	subnet_id      = "${aws_subnet.private_availability_zone2.id}"
	route_table_id = "${aws_route_table.private.id}"
}
