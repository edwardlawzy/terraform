resource "aws_iam_role" "eks" {
  name = "${var.project_name}-eks-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role" "eks-bastion-role" {
  name = "${var.project_name}-eks-bastion-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      }
    }
  ]
}
POLICY
}



resource "aws_iam_role_policy_attachment" "eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}

resource "aws_iam_role_policy_attachment" "eks-bastion-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-bastion-role.name
}

resource "aws_eks_access_entry" "bastion" {
  cluster_name    = aws_eks_cluster.eks.name
  # The ARN of the IAM User or Role you want to grant access to
  principal_arn   = aws_iam_role.eks-bastion-role.arn
  type            = "EC2" 
}

resource "aws_eks_access_policy_association" "bastion" {
  cluster_name = aws_eks_cluster.eks.name
  principal_arn = aws_eks_access_entry.bastion.principal_arn
  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  
  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_cluster" "eks" {
  name     = "${var.project_name}-eks-cluster"
  version  = "1.30"
  role_arn = aws_iam_role.eks-bastion-role.arn

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true

    subnet_ids = var.private_subnet_ids
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks-bastion-policy]
}