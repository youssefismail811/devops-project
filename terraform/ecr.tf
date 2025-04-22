#--------------------------------------#
# ECR Repository
#--------------------------------------#

resource "aws_ecr_repository" "my_repo" {
  name                 = "devops-ecr-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "devops-ecr-repo"
    Environment = "dev"
  }
}
