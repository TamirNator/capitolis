output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "nlb_arn" {
  value = aws_lb.my_app_nlb.arn
}

output "nlb_dns_name" {
  value = aws_lb.my_app_nlb.dns_name
}

output "nlb_name" {
  value = aws_lb.my_app_nlb.name
}