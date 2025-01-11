module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.17.0"

  name       = "cinema-vpc"
  cidr       = var.vpc_cidr
  azs        = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.0.0/27", "10.0.0.32/27"]
  private_subnets = ["10.0.0.64/27", "10.0.0.96/27"]
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
    instance_types = ["t3.medium"]
    key_name       = "cinema"
  }
  node_iam_role_additional_policies = {
    EKSPolicy = aws_iam_policy.eks_policy.arn
  }
  eks_managed_node_groups = {
    main = {
      ami_type      = "AL2_x86_64"
      instance_type = "t3.medium"

      min_size = 1
      max_size = 5
      desired_size = 1
      iam_role_additional_policies = {
        "CreateVolumePolicy" = aws_iam_policy.eks_policy.arn
      }
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
}

resource "kubernetes_role_binding" "dev_role_binding" {
  metadata {
    name      = "eks-dev-role"
    namespace = "default"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "eks-dev-role"
  }
  subject {
    kind      = "User"
    name      = "admin"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_role" "dev_role" {
  metadata {
    name = "eks-dev-role"
  }

  rule {
    api_groups     = [""]
    resources      = ["pods"]
    verbs          = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs      = ["get", "list"]
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
      }
    ]
  })
}