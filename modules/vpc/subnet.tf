
resource "aws_subnet" "public" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_public_subnet, var.new_bits, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  #cidr_block        = var.private_subnets[count.index]
  cidr_block = cidrsubnet(var.vpc_private_subnet, var.new_bits, count.index)########
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

resource "aws_db_subnet_group" "rds_sng" {
  name       = "${var.project_name}-rds-sng"
  subnet_ids = aws_subnet.private.id
  #subnet_ids = aws_subnet.public[0].id
  tags       = { Name = "RDS Subnet Group" }
}