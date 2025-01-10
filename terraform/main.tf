module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.17.0"

  name       = "cinema-vpc"
  cidr       = var.vpc_cidr
  azs        = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.0.0/28", "10.0.0.16/28"]
  private_subnets = ["10.0.0.32/28", "10.0.0.48/28"]
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "cinema"
  cluster_version = "1.31"

  bootstrap_self_managed_addons = false
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  # Optional
  cluster_endpoint_public_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t2.large"]
  }
  node_security_group_name = "EKSSecurityGroup"
  create_iam_role = true
  iam_role_name   = "EKSClusterRole"
  node_iam_role_name = "EKSNodeRole"
  cluster_security_group_name = "eks"
  create_node_security_group = false
  eks_managed_node_groups = {
    main = {
      ami_type       = "AL2023_x86_64_STANDARD"
      min_size     = 1
      max_size     = 10
      desired_size = 1
    }
  }
  node_security_group_additional_rules = {
    hybrid-all = {
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all traffic from remote node/pod network"
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