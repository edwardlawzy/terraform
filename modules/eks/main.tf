# provider "aws" {
#   region = "us-east-1"
# }

# terraform {
#   required_version = ">= 1.0"

#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.53"
#     }
#   }
# }

# resource "aws_iam_role" "eks" {
#   name = "${var.project_name}-eks-cluster-role"

#   assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "eks.amazonaws.com"
#       }
#     }
#   ]
# }
# POLICY
# }

# resource "aws_iam_role_policy_attachment" "eks" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = aws_iam_role.eks.name
# }

# resource "aws_eks_cluster" "eks" {
#   name     = "${var.project_name}-eks-cluster"
#   version  = "1.30"
#   role_arn = aws_iam_role.eks.arn

#   vpc_config {
#     endpoint_private_access = false
#     endpoint_public_access  = true

#     subnet_ids = var.private_subnet_ids
#   }

#   access_config {
#     authentication_mode                         = "API"
#     bootstrap_cluster_creator_admin_permissions = true
#   }

#   depends_on = [aws_iam_role_policy_attachment.eks]
# }

# resource "aws_iam_role" "nodes" {
#   name = "${var.project_name}-eks-cluster-nodes"

#   assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       }
#     }
#   ]
# }
# POLICY
# }

# # This policy now includes AssumeRoleForPodIdentity for the Pod Identity Agent
# resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   role       = aws_iam_role.nodes.name
# }

# resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.nodes.name
# }

# resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   role       = aws_iam_role.nodes.name
# }

# resource "aws_eks_node_group" "general" {
#   cluster_name    = aws_eks_cluster.eks.name
#   version         = "1.30"
#   node_group_name = "general"
#   node_role_arn   = aws_iam_role.nodes.arn

#   subnet_ids = var.private_subnet_ids

#   capacity_type  = "ON_DEMAND"
#   instance_types = ["t3.large"]

#   scaling_config {
#     desired_size = 1
#     max_size     = 10
#     min_size     = 1
#   }

#   update_config {
#     max_unavailable = 1
#   }

#   labels = {
#     role = "general"
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
#     aws_iam_role_policy_attachment.amazon_eks_cni_policy,
#     aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
#   ]

#   # Allow external changes without Terraform plan difference
#   lifecycle {
#     ignore_changes = [scaling_config[0].desired_size]
#   }
# }

# resource "aws_iam_user" "developer" {
#   name = "developer"
# }

# resource "aws_iam_policy" "developer_eks" {
#   name = "AmazonEKSDeveloperPolicy"

#   policy = <<POLICY
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "eks:DescribeCluster",
#                 "eks:ListClusters"
#             ],
#             "Resource": "*"
#         }
#     ]
# }
# POLICY
# }

# resource "aws_iam_user_policy_attachment" "developer_eks" {
#   user       = aws_iam_user.developer.name
#   policy_arn = aws_iam_policy.developer_eks.arn
# }

# resource "aws_eks_access_entry" "developer" {
#   cluster_name      = aws_eks_cluster.eks.name
#   principal_arn     = aws_iam_user.developer.arn
#   kubernetes_groups = ["my-viewer"]
# }

# data "aws_caller_identity" "current" {}

# resource "aws_iam_role" "eks_admin" {
#   name = "${var.project_name}-eks-admin"

#   assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
#       }
#     }
#   ]
# }
# POLICY
# }

# resource "aws_iam_policy" "eks_admin" {
#   name = "AmazonEKSAdminPolicy"

#   policy = <<POLICY
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "eks:*"
#             ],
#             "Resource": "*"
#         },
#         {
#             "Effect": "Allow",
#             "Action": "iam:PassRole",
#             "Resource": "*",
#             "Condition": {
#                 "StringEquals": {
#                     "iam:PassedToService": "eks.amazonaws.com"
#                 }
#             }
#         }
#     ]
# }
# POLICY
# }

# resource "aws_iam_role_policy_attachment" "eks_admin" {
#   role       = aws_iam_role.eks_admin.name
#   policy_arn = aws_iam_policy.eks_admin.arn
# }

# resource "aws_iam_user" "manager" {
#   name = "manager"
# }

# resource "aws_iam_policy" "eks_assume_admin" {
#   name = "AmazonEKSAssumeAdminPolicy"

#   policy = <<POLICY
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "sts:AssumeRole"
#             ],
#             "Resource": "${aws_iam_role.eks_admin.arn}"
#         }
#     ]
# }
# POLICY
# }

# resource "aws_iam_user_policy_attachment" "manager" {
#   user       = aws_iam_user.manager.name
#   policy_arn = aws_iam_policy.eks_assume_admin.arn
# }

# # Best practice: use IAM roles due to temporary credentials
# resource "aws_eks_access_entry" "manager" {
#   cluster_name      = aws_eks_cluster.eks.name
#   principal_arn     = aws_iam_role.eks_admin.arn
#   kubernetes_groups = ["my-admin"]
# }

# data "aws_eks_cluster" "eks" {
#   name = aws_eks_cluster.eks.name
# }

# data "aws_eks_cluster_auth" "eks" {
#   name = aws_eks_cluster.eks.name
# }

# provider "helm" {
#   kubernetes = {
#     host                   = data.aws_eks_cluster.eks.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
#     token                  = data.aws_eks_cluster_auth.eks.token
#   }
# }

# resource "helm_release" "metrics_server" {
#   name = "metrics-server"

#   repository = "https://kubernetes-sigs.github.io/metrics-server/"
#   chart      = "metrics-server"
#   namespace  = "kube-system"
#   version    = "3.12.1"

#   values = [file("${path.module}/metrics-values.yaml")]

#   depends_on = [aws_eks_node_group.general]
# }

# resource "aws_eks_addon" "pod_identity" {
#   cluster_name  = aws_eks_cluster.eks.name
#   addon_name    = "eks-pod-identity-agent"
#   addon_version = "v1.2.0-eksbuild.1"
# }

# resource "aws_iam_role" "cluster_autoscaler" {
#   name = "${aws_eks_cluster.eks.name}-cluster-autoscaler"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "sts:AssumeRole",
#           "sts:TagSession"
#         ]
#         Principal = {
#           Service = "pods.eks.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "cluster_autoscaler" {
#   name = "${aws_eks_cluster.eks.name}-cluster-autoscaler"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "autoscaling:DescribeAutoScalingGroups",
#           "autoscaling:DescribeAutoScalingInstances",
#           "autoscaling:DescribeLaunchConfigurations",
#           "autoscaling:DescribeScalingActivities",
#           "autoscaling:DescribeTags",
#           "ec2:DescribeImages",
#           "ec2:DescribeInstanceTypes",
#           "ec2:DescribeLaunchTemplateVersions",
#           "ec2:GetInstanceTypesFromInstanceRequirements",
#           "eks:DescribeNodegroup"
#         ]
#         Resource = "*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "autoscaling:SetDesiredCapacity",
#           "autoscaling:TerminateInstanceInAutoScalingGroup"
#         ]
#         Resource = "*"
#       },
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
#   policy_arn = aws_iam_policy.cluster_autoscaler.arn
#   role       = aws_iam_role.cluster_autoscaler.name
# }

# resource "aws_eks_pod_identity_association" "cluster_autoscaler" {
#   cluster_name    = aws_eks_cluster.eks.name
#   namespace       = "kube-system"
#   service_account = "cluster-autoscaler"
#   role_arn        = aws_iam_role.cluster_autoscaler.arn
# }

# resource "helm_release" "cluster_autoscaler" {
#   name = "autoscaler"

#   repository = "https://kubernetes.github.io/autoscaler"
#   chart      = "cluster-autoscaler"
#   namespace  = "kube-system"
#   version    = "9.37.0"

#   set =[ {
#     name  = "rbac.serviceAccount.name"
#     value = "cluster-autoscaler"},
#     {
#     name  = "autoDiscovery.clusterName"
#     value = aws_eks_cluster.eks.name
#   },
#    {
#     name  = "awsRegion"
#     value = "us-east-1"
#   }

# ]
# }

# data "aws_iam_policy_document" "aws_lbc" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["pods.eks.amazonaws.com"]
#     }

#     actions = [
#       "sts:AssumeRole",
#       "sts:TagSession"
#     ]
#   }
# }

# resource "aws_iam_role" "aws_lbc" {
#   name               = "${aws_eks_cluster.eks.name}-aws-lbc"
#   assume_role_policy = data.aws_iam_policy_document.aws_lbc.json
# }

# resource "aws_iam_policy" "aws_lbc" {
#   policy = file("./iam/AWSLoadBalancerController.json")
#   name   = "AWSLoadBalancerController"
# }

# resource "aws_iam_role_policy_attachment" "aws_lbc" {
#   policy_arn = aws_iam_policy.aws_lbc.arn
#   role       = aws_iam_role.aws_lbc.name
# }

# resource "aws_eks_pod_identity_association" "aws_lbc" {
#   cluster_name    = aws_eks_cluster.eks.name
#   namespace       = "kube-system"
#   service_account = "aws-load-balancer-controller"
#   role_arn        = aws_iam_role.aws_lbc.arn
# }

# resource "helm_release" "aws_lbc" {
#   name = "aws-load-balancer-controller"

#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   version    = "1.8.1"

#   set=[ {
#     name  = "clusterName"
#     value = aws_eks_cluster.eks.name
#   },
#    {
#     name  = "serviceAccount.name"
#     value = "aws-load-balancer-controller"
#   },

#  {
#     name  = "vpcId"
#     value = aws_vpc.main.id
#   }

#   ]
# }

# # main.tf (Combined File for NGINX & Argo CD)

# # 1. Install the NGINX Ingress Controller using Helm
# #    Note: We remove the 'values' file reference and add necessary args directly.
# resource "helm_release" "external_nginx" {
#   name             = "external"
#   repository       = "https://kubernetes.github.io/ingress-nginx"
#   chart            = "ingress-nginx"
#   namespace        = "ingress"
#   create_namespace = true
#   version          = "4.10.1" # Use the specific version you need

#   # Values for the NGINX Controller deployment to enable SSL Passthrough
#   # which is essential for Argo CD's mixed traffic (HTTPS/gRPC).
#   set ={
#     name  = "controller.extraArgs.enable-ssl-passthrough"
#     value = "true"
#   }
# }

# # 2. Deploy the Ingress resource for Argo CD
# #    This resource requires the NGINX Ingress Controller (installed above).
# resource "kubernetes_ingress_v1" "argocd_nginx_ingress" {
#   metadata {
#     name      = "argocd-server-ingress"
#     namespace = "argocd" # Argo CD is typically installed in the 'argocd' namespace
#     annotations = {
#       # Use the NGINX Ingress Class
#       "kubernetes.io/ingress.class"               = "nginx"
#       # Enable SSL Passthrough to handle Argo CD's single port for HTTPS and gRPC
#       "nginx.ingress.kubernetes.io/ssl-passthrough" = "true"
#       # Force redirect to HTTPS
#       "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
#     }
#   }

#   spec {
#     ingress_class_name = "nginx"

#     rule {
#       host = eks.endpoint # Your desired domain for Argo CD
#       http {
#         path {
#           path      = "/"
#           path_type = "Prefix"
#           backend {
#             service {
#               name = "argocd-server" # The service name of the Argo CD API server
#               port {
#                 number = 80 # The HTTPS port of the argocd-server service
#               }
#             }
#           }
#         }
#       }
#     }
    
#     # Configure TLS
#     # tls {
#     #   hosts = ["argocd.example.com"]
#     #   # This secret is created by Argo CD itself
#     #   secret_name = "argocd-server-tls" 
#     # }
#   }
# }

# # resource "helm_release" "external_nginx" {
# #   name = "external"

# #   repository       = "https://kubernetes.github.io/ingress-nginx"
# #   chart            = "ingress-nginx"
# #   namespace        = "ingress"
# #   create_namespace = true
# #   version          = "4.10.1"

# #   values = [file("${path.module}/ingress-values.yaml")]

# #   depends_on = [helm_release.aws_lbc]
# # }

# resource "helm_release" "cert_manager" {
#   name = "cert-manager"

#   repository       = "https://charts.jetstack.io"
#   chart            = "cert-manager"
#   namespace        = "cert-manager"
#   create_namespace = true
#   version          = "v1.15.0"

#   set = {
#     name  = "installCRDs"
#     value = "true"
#   }

# }

# data "aws_iam_policy_document" "ebs_csi_driver" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["pods.eks.amazonaws.com"]
#     }

#     actions = [
#       "sts:AssumeRole",
#       "sts:TagSession"
#     ]
#   }
# }

# resource "aws_iam_role" "ebs_csi_driver" {
#   name               = "${aws_eks_cluster.eks.name}-ebs-csi-driver"
#   assume_role_policy = data.aws_iam_policy_document.ebs_csi_driver.json
# }

# resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
#   role       = aws_iam_role.ebs_csi_driver.name
# }

# # Optional: only if you want to encrypt the EBS drives
# resource "aws_iam_policy" "ebs_csi_driver_encryption" {
#   name = "${aws_eks_cluster.eks.name}-ebs-csi-driver-encryption"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "kms:Decrypt",
#           "kms:GenerateDataKeyWithoutPlaintext",
#           "kms:CreateGrant"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

# # Optional: only if you want to encrypt the EBS drives
# resource "aws_iam_role_policy_attachment" "ebs_csi_driver_encryption" {
#   policy_arn = aws_iam_policy.ebs_csi_driver_encryption.arn
#   role       = aws_iam_role.ebs_csi_driver.name
# }

# resource "aws_eks_pod_identity_association" "ebs_csi_driver" {
#   cluster_name    = aws_eks_cluster.eks.name
#   namespace       = "kube-system"
#   service_account = "ebs-csi-controller-sa"
#   role_arn        = aws_iam_role.ebs_csi_driver.arn
# }

# resource "aws_eks_addon" "ebs_csi_driver" {
#   cluster_name             = aws_eks_cluster.eks.name
#   addon_name               = "aws-ebs-csi-driver"
#   addon_version            = "v1.31.0-eksbuild.1"
#   service_account_role_arn = aws_iam_role.ebs_csi_driver.arn

#   depends_on = [aws_eks_node_group.general]
# }

# data "tls_certificate" "eks" {
#   url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
# }

# resource "aws_iam_openid_connect_provider" "eks" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
#   url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer
# }

# resource "aws_efs_file_system" "eks" {
#   creation_token = "eks"

#   performance_mode = "generalPurpose"
#   throughput_mode  = "bursting"
#   encrypted        = true

#   # lifecycle_policy {
#   #   transition_to_ia = "AFTER_30_DAYS"
#   # }
# }

# resource "aws_efs_mount_target" "zone_a" {
#   file_system_id  = aws_efs_file_system.eks.id
#   subnet_id       = aws_subnet.private_zone1.id
#   security_groups = [aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id]
# }

# resource "aws_efs_mount_target" "zone_b" {
#   file_system_id  = aws_efs_file_system.eks.id
#   subnet_id       = aws_subnet.private_zone2.id
#   security_groups = [aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id]
# }

# data "aws_iam_policy_document" "efs_csi_driver" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
#       values   = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
#     }

#     principals {
#       identifiers = [aws_iam_openid_connect_provider.eks.arn]
#       type        = "Federated"
#     }
#   }
# }

# resource "aws_iam_role" "efs_csi_driver" {
#   name               = "${aws_eks_cluster.eks.name}-efs-csi-driver"
#   assume_role_policy = data.aws_iam_policy_document.efs_csi_driver.json
# }

# resource "aws_iam_role_policy_attachment" "efs_csi_driver" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
#   role       = aws_iam_role.efs_csi_driver.name
# }

# resource "helm_release" "efs_csi_driver" {
#   name = "aws-efs-csi-driver"

#   repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
#   chart      = "aws-efs-csi-driver"
#   namespace  = "kube-system"
#   version    = "3.0.5"

#   set=[ {
#     name  = "controller.serviceAccount.name"
#     value = "efs-csi-controller-sa"
#   },

#  {
#     name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.efs_csi_driver.arn
#   }]

  
# }

# # Optional since we already init helm provider (just to make it self contained)
# data "aws_eks_cluster" "eks_v2" {
#   name = aws_eks_cluster.eks.name
# }

# # Optional since we already init helm provider (just to make it self contained)
# data "aws_eks_cluster_auth" "eks_v2" {
#   name = aws_eks_cluster.eks.name
# }

# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.eks_v2.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_v2.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.eks_v2.token
# }

# resource "kubernetes_storage_class_v1" "efs" {
#   metadata {
#     name = "efs"
#   }

#   storage_provisioner = "efs.csi.aws.com"

#   parameters = {
#     provisioningMode = "efs-ap"
#     fileSystemId     = aws_efs_file_system.eks.id
#     directoryPerms   = "700"
#   }

#   mount_options = ["iam"]

#   depends_on = [helm_release.efs_csi_driver]
# }

# resource "helm_release" "secrets_csi_driver" {
#   name = "secrets-store-csi-driver"

#   repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
#   chart      = "secrets-store-csi-driver"
#   namespace  = "kube-system"
#   version    = "1.4.3"

#   # MUST be set if you use ENV variables
#   set= {
#     name  = "syncSecret.enabled"
#     value = true
#   }

#   depends_on = [helm_release.efs_csi_driver]
# }

# resource "helm_release" "secrets_csi_driver_aws_provider" {
#   name = "secrets-store-csi-driver-provider-aws"

#   repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
#   chart      = "secrets-store-csi-driver-provider-aws"
#   namespace  = "kube-system"
#   version    = "0.3.9"

#   depends_on = [helm_release.secrets_csi_driver]
# }

# data "aws_iam_policy_document" "myapp_secrets" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
#       values   = ["system:serviceaccount:12-example:myapp"]
#     }

#     principals {
#       identifiers = [aws_iam_openid_connect_provider.eks.arn]
#       type        = "Federated"
#     }
#   }
# }

# resource "aws_iam_role" "myapp_secrets" {
#   name               = "${aws_eks_cluster.eks.name}-myapp-secrets"
#   assume_role_policy = data.aws_iam_policy_document.myapp_secrets.json
# }

# resource "aws_iam_policy" "myapp_secrets" {
#   name = "${aws_eks_cluster.eks.name}-myapp-secrets"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "secretsmanager:GetSecretValue",
#           "secretsmanager:DescribeSecret"
#         ]
#         Resource = "*" # "arn:*:secretsmanager:*:*:secret:my-secret-kkargS"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "myapp_secrets" {
#   policy_arn = aws_iam_policy.myapp_secrets.arn
#   role       = aws_iam_role.myapp_secrets.name
# }

# output "myapp_secrets_role_arn" {
#   value = aws_iam_role.myapp_secrets.arn
# }