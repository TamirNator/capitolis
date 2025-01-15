module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.17.0"

  name       = "cinema-vpc"
  cidr       = var.vpc_cidr
  azs        = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.0.0/26", "10.0.0.64/26"]
  private_subnets = ["10.0.0.128/26", "10.0.0.192/26"]
  enable_nat_gateway  = true
  single_nat_gateway  = true
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.31"
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access = true
  
  cluster_addons = {
    aws-ebs-csi-driver = {}
    vpc-cni = {}
    coredns = {}
    kube-proxy = {}
  }
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    instance_types = ["t3.large"]
    key_name       = "cinema"
  }
  node_iam_role_additional_policies = {
    EKSPolicy = aws_iam_policy.eks_policy.arn
  }
  access_entries = {
      jenkins_service_account = {
        principal_arn = aws_iam_role.jenkins_service_account_role.arn
        username      = "jenkins-service-account"
        groups        = ["eks-dev-role"]
      }
    }
  eks_managed_node_groups = {
    main = {
      ami_type      = "AL2_x86_64"
      instance_type = "t3.medium"

      min_size = 1
      max_size = 5
      desired_size = 1
      iam_role_additional_policies = {
        "EKSPolicy" = aws_iam_policy.eks_policy.arn
      }
      enable_bootstrap_user_data = true
      post_bootstrap_user_data = <<-EOT
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==BOUNDARY=="

--==BOUNDARY==
Content-Type: text/cloud-config; charset="us-ascii"

#cloud-config
packages:
  - docker

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
set -o xtrace
yum update -y
amazon-linux-extras enable docker
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

--==BOUNDARY==--
EOT
    }
  }

  cluster_security_group_additional_rules = {
    hybrid-all = {
      cidr_blocks = [module.vpc.vpc_cidr_block]
      description = "Allow traffic from all"
      from_port   = 0
      to_port     = 0
      protocol    = "all"
      type        = "ingress"
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
  depends_on = [ module.vpc ]
}

resource "kubernetes_role_binding" "jenkins_role_binding" {
  metadata {
    name      = "jenkins-dev-role-binding"
    namespace = "jenkins"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "jenkins-dev-role"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "jenkins"
    api_group = ""
  }
}

resource "kubernetes_role" "jenkins_role" {
  metadata {
    name = "jenkins-dev-role"
    namespace = "jenkins"
  }
  rule {
    api_groups     = [""]
    resources      = ["pods", "secrets", "serviceaccounts"]
    verbs          = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_role_binding" "dev_role_binding" {
  metadata {
    name      = "eks-dev-role-binding"
    namespace = "default"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.dev_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "jenkins"
    api_group = ""
  }
}

resource "kubernetes_role" "dev_role" {
  metadata {
    name = "eks-dev-role"
    namespace = "default"
  }
  rule {
    api_groups     = [""]
    resources      = ["pods", "secrets", "serviceaccounts", "services"]
    verbs          = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

# IAM Role for Jenkins Service Account
resource "aws_iam_role" "jenkins_service_account_role" {
  name               = "jenkins-service-account-role"
  assume_role_policy = data.aws_iam_policy_document.jenkins_service_account_assume_role_policy.json
}

data "aws_iam_policy_document" "jenkins_service_account_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:jenkins:default"]
    }
  }
}

resource "aws_iam_policy" "eks_policy" {
  name        = "EKS-Policy"
  description = "Policy to allow Actions for EKS"
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ec2:CreateVolume",
          "ec2:CreateTags",
          "ec2:CreateSnapshot",
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:ModifyVolume",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInstances",
          "ec2:DescribeSnapshots",
          "ec2:DescribeTags",
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumesModifications"
        ],
        Resource = "*"
      },
      {
			"Sid": "AllowECR",
			"Effect": "Allow",
			"Action": [
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage"
        ],
			"Resource": "*"
		  }
    ]
  })
}

# resource "aws_lb" "my_app_nlb" {
#   name               = "cinema-nlb"
#   internal           = false
#   load_balancer_type = "network"
#   security_groups    = [aws_security_group.my_app_sg.id]
#   subnets            = module.vpc.private_subnets
# }

# # Security Group for NLB
# resource "aws_security_group" "my_app_sg" {
#   name        = "cinema-nlb-sg"
#   description = "Security group for My App NLB"
#   vpc_id      = module.vpc.vpc_id

#   # Allow incoming traffic on port 80 (HTTP) or 443 (if using HTTPS in the future)
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # Allow all outbound traffic
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "cinema-nlb-sg"
#   }
# }

# resource "aws_lb_target_group" "my_app_tg" {
#   name        = "movies-service-tg"
#   port        = 5001 # Port on your application
#   protocol    = "TCP"
#   vpc_id      = module.vpc.vpc_id
#   target_type = "ip"
# }

# resource "aws_lb_listener" "my_app_listener" {
#   load_balancer_arn = aws_lb.my_app_nlb.arn
#   port              = 80
#   protocol          = "TCP" # Changed from HTTP to TCP

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.my_app_tg.arn
#   }
# }