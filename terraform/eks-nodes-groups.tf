# This file contains the configuration for the EKS node groups.
# It creates a node group with the specified instance type and scaling configuration.
# It also attaches the necessary IAM policies to the node group role.
#---------------------------------------#
# IAM role for eks nodes
#---------------------------------------#
resource "aws_iam_role" "nodes_general" {
  name = "eks-node-group-general"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

#---------------------------------------#
# Node Group Eks Nodes
#---------------------------------------#
resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "general-node-group"
  node_role_arn   = aws_iam_role.nodes_general.arn

  subnet_ids = [
    aws_subnet.Private_Subnet_1.id,
    aws_subnet.Private_Subnet_2.id
  ]

  

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
    instance_types = [ "t3.small" ]
    ami_type       = "AL2_x86_64"
    disk_size      = 20
    capacity_type  = "ON_DEMAND"        # Valid values: ON_DEMAND, SPOT(Careful with this one as it can be terminated by AWS)
    force_update_version = false        # Force update if existing pods are unable to be drained due to disruption budget (Admin solve this problem)
  depends_on = [
    aws_iam_role_policy_attachment.worker_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.worker_node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.worker_node_AmazonEKS_CNI_Policy
  ]
}

#----------------------------------------#
# Node Group IAM Policy Attachments
#----------------------------------------#
resource "aws_iam_role_policy_attachment" "worker_node_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.nodes_general.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "worker_node_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.nodes_general.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "worker_node_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.nodes_general.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
