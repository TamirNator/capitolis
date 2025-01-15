# module "karpenter" {
#   source = "terraform-aws-modules/eks/aws//modules/karpenter"

#   cluster_name = module.eks.cluster_name

#   create_node_iam_role = false
#   node_iam_role_arn    = module.eks.eks_managed_node_groups["main"].iam_role_arn

#   # Since the node group role will already have an access entry
#   create_access_entry = false

#   tags = {
#     Environment = "dev"
#     Terraform   = "true"
#   }
# }

# output "name" {
#   value = module.eks.eks_managed_node_groups["main"].iam_role_arn
# }