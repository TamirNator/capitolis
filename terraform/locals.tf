locals {
  new_role = {
    rolearn  = aws_iam_role.jenkins_service_account_role.arn
    username = "jenkins-role"
    groups   = ["system:masters"]
  }

  existing_map_roles = can(yamldecode(data.kubernetes_config_map.aws_auth.data["mapRoles"])) ? yamldecode(data.kubernetes_config_map.aws_auth.data["mapRoles"]): []

  merged_map_roles = jsonencode(concat(local.existing_map_roles, [local.new_role]))
}

data "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
}