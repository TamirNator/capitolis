resource "helm_release" "jenkins" {
  name       = "jenkins"
  chart      = "../deploy/jenkins"
  namespace  = "jenkins"
  create_namespace = true
  set {
    name = "persistence.storageClass"
    value = "gp2"
  }
  values = [file("../deploy/jenkins/values-ci.yaml")]
}

# Deploy NGINX Ingress
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  namespace  = "nginx-ingress"
  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
}


resource "helm_release" "argocd" {
  name       = "argocd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  namespace  = "argocd"
  create_namespace = true
}