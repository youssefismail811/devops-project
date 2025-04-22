
data "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  
}

resource "aws_security_group" "main_sg" {
  name        = "devops-services-sg"
  description = "Security group for Jenkins and DevOps services"
  vpc_id      = aws_vpc.mainvpc.id
  ingress {
    description = "SSH from your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidrs] 
  }

  ingress {
    description = "Jenkins UI (Port 8080)"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.cidrs] 
  }

  ingress {
    description = "SonarQube UI (Port 9000)"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = [var.cidrs]
  }

  ingress {
    description = "Vault UI/API (Port 8200)"
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = [var.cidrs]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidrs]
  }

  tags = {
    Name = "devops-services-sg"
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
  ami                         = var.chami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.Public_Subnet_1.id
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
  ami                           = var.chami
  instance_type                 = "t3.medium"
  subnet_id                     = aws_subnet.Public_Subnet_1.id
  key_name                      = var.key_name
  vpc_security_group_ids        = [ aws_security_group.main_sg.id ]
  iam_instance_profile          = data.aws_iam_instance_profile.ec2_instance_profile.name
  associate_public_ip_address   = true

  tags = {
    Name = "SonarQube EC2"
  }
}