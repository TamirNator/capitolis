resource "helm_release" "jenkins" {
  name       = "jenkins"
  chart      = "jenkins"
  repository = "https://charts.jenkins.io"
  namespace  = "jenkins"
  create_namespace = true
  set {
    name = "persistence.storageClass"
    value = "gp2"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.jenkins_service_account_role.arn
  }
  depends_on = [ module.eks ]
}

# Deploy NGINX Ingress
# resource "helm_release" "nginx_ingress" {
#   name       = "nginx-ingress"
#   chart      = "ingress-nginx"
#   repository = "https://kubernetes.github.io/ingress-nginx"
#   namespace  = "nginx-ingress"
#   create_namespace = true

#   set {
#     name  = "controller.service.type"
#     value = "LoadBalancer"
#   }
#   depends_on = [ module.eks ]
# }


# resource "helm_release" "argocd" {
#   name       = "argocd"
#   chart      = "argo-cd"
#   repository = "https://argoproj.github.io/argo-helm"
#   namespace  = "argocd"
#   create_namespace = true
# }