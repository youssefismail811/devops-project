
data "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  
}

# -------------------------------#
# Security Group
# -------------------------------#
resource "aws_security_group" "main_sg" {
  vpc_id = aws_vpc.mainvpc.id
  name   = "Main Security Group Allow SSH and HTTP"
  description = "Main security group for the VPC"

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ var.cidrs ] 
  }

  ingress {
    description = "Jenkins Web UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [ var.cidrs ]
  }
  ingress {
    description = "Valut Web UI"
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = [ var.cidrs ]
  }
  ingress {
    description = "Allow HTTPS"
    from_port = 443 
    to_port = 443 
    protocol = "tcp"
    cidr_blocks = [ var.cidrs ]
  }
  ingress {
    description = "SonarQube Web UI"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = [ var.cidrs ]
  }
  ingress {
  description = "HTTP access"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = [ var.cidrs ]
}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ var.cidrs ]
  }

  tags = {
    Name = "Main Security Group"
  }
}

# -------------------------------#
# Jenkins EC2 Instance
# -------------------------------#
resource "aws_instance" "Jenkins_Instance" {
  ami                           = var.ami
  instance_type                 = var.instance_type
  subnet_id                     = aws_subnet.Public_Subnet_1.id
  vpc_security_group_ids        = [ aws_security_group.main_sg.id ]
  associate_public_ip_address   = true
  key_name                      = var.key_name
  iam_instance_profile          = data.aws_iam_instance_profile.ec2_instance_profile.name
 
  
  tags = {
    Name = "Jenkins Instance"
  }
}

#--------------------------------#
# Vault EC2 Instance
#--------------------------------#
resource "aws_instance" "vault" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.Private_Subnet_1.id
  key_name                    = var.key_name
  vpc_security_group_ids      = [ aws_security_group.main_sg.id ]
  iam_instance_profile        = data.aws_iam_instance_profile.ec2_instance_profile.name
  associate_public_ip_address = true

  tags = {
    Name = "Vault EC2"
  }
}

# -------------------------------#
# SonarQube EC2
# -------------------------------#
resource "aws_instance" "sonarqube" {
  ami                           = var.ami
  instance_type                 = var.instance_type
  subnet_id                     = aws_subnet.Private_Subnet_2.id
  key_name                      = var.key_name
  vpc_security_group_ids        = [ aws_security_group.main_sg.id ]
  iam_instance_profile          = data.aws_iam_instance_profile.ec2_instance_profile.name
  associate_public_ip_address   = true

  tags = {
    Name = "SonarQube EC2"
  }
}