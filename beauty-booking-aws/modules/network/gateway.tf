resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

resource "aws_eip" "nat" {
  count = length(var.public_subnets) > 0 ? 1 : 0
  vpc   = true

  tags = {
    Name = "${var.environment}-nat-eip"
  }

  # To ensure proper ordering, add an explicit dependency on the Internet Gateway
  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count         = length(var.public_subnets) > 0 ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.environment}-nat-gateway"
  }

  # To ensure proper ordering, add an explicit dependency on the Internet Gateway
  depends_on = [aws_internet_gateway.main]
}