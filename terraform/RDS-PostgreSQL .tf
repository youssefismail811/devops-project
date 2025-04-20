# This Terraform script creates an RDS PostgreSQL instance in a VPC with two private subnets.
#-----------------------------------------#
# # RDS Subnet Group
#-----------------------------------------#
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [
    aws_subnet.Private_Subnet_1.id,
    aws_subnet.Private_Subnet_2.id
  ]

  tags = {
    Name = "RDS Subnet Group"
  }
}

#----------------------------------------#
# # RDS Security Group
#----------------------------------------#
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow DB access"
  vpc_id      = aws_vpc.mainvpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidrs]
  }

  tags = {
    Name = "RDS SG"
  }
}

#----------------------------------------#
# # RDS PostgreSQL Instance
#----------------------------------------#
resource "aws_db_instance" "postgres" {
  identifier         = "ecommerce-postgres"
  engine             = "postgres"
  engine_version     = "11.22"
  instance_class     = "db.t3.micro"
  allocated_storage  = 20
  storage_type       = "gp2"
  username           = var.db_username
  password           = var.db_password
  db_name            = var.db_name
  skip_final_snapshot = true
  publicly_accessible = false

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  tags = {
    Name = "E-Commerce Postgres"
  }
}
