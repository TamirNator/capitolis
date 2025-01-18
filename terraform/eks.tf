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
    amazon-cloudwatch-observability = {}
    metrics-server = {}
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnets

  eks_managed_node_group_defaults = {
    instance_types = ["t2.medium"]
  }
  node_iam_role_additional_policies = {
    EKSPolicy = aws_iam_policy.eks_policy.arn
  }
  access_entries = {
      jenkins_service_account = {
        principal_arn = aws_iam_role.jenkins_service_account_role.arn
        username      = "jenkins-service-account"
        kubernetes_groups        = ["eks-dev-role"]
      }
    }
  eks_managed_node_groups = {
    main = {
      ami_type      = "AL2_x86_64"
      min_size = 3
      max_size = 10
      desired_size = 3
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