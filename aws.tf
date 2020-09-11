resource "aws_vpc" "awsvpc" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "database-vpc"
  }
}

resource "aws_subnet" "aws_subnet_1" {
  vpc_id     = aws_vpc.awsvpc.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "aws_subnet_2" {
  vpc_id     = aws_vpc.awsvpc.id
  cidr_block = "10.1.2.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_route_table_association" "rt_subnet_1" {
  subnet_id      = aws_subnet.aws_subnet_1.id
  route_table_id = aws_vpc.awsvpc.default_route_table_id
  depends_on = [ aws_subnet.aws_subnet_1 ]
}

resource "aws_route_table_association" "rt_subnet_2" {
  subnet_id      = aws_subnet.aws_subnet_2.id
  route_table_id = aws_vpc.awsvpc.default_route_table_id
  depends_on = [ aws_subnet.aws_subnet_2 ]
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.awsvpc.id

  tags = {
    Name = "my-first-ig"
  }
}

resource "aws_route" "route-ig" {
  route_table_id            = aws_vpc.awsvpc.default_route_table_id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.ig.id
  depends_on = [ aws_internet_gateway.ig ]
}

resource "aws_default_security_group" "sg_rds" {
  vpc_id      = aws_vpc.awsvpc.id

  ingress {
    description = "Allow only GKE slave nodes to connect"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [ "${data.google_compute_instance.node1.network_interface.0.access_config.0.nat_ip}/32" ,
                    "${data.google_compute_instance.node2.network_interface.0.access_config.0.nat_ip}/32" ,
                    "${data.google_compute_instance.node3.network_interface.0.access_config.0.nat_ip}/32" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_gke_nodes"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = var.subnet_group
  subnet_ids = [aws_subnet.aws_subnet_1.id , aws_subnet.aws_subnet_2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = var.db
  username             = var.userrds
  password             = var.passrds
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name = aws_db_subnet_group.default.name
  publicly_accessible  = true
  skip_final_snapshot  = true
  depends_on           = [ aws_db_subnet_group.default ]
}