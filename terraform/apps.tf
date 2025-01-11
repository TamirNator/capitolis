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
  # Mount JCasC configuration
#   set {
#     name  = "controller.JCasC.configScripts.jenkins"
#     value = file("${path.module}/../jenkins-config/casc.yaml")
#   }

  # Install Jenkins plugins
  set_list {
    name  = "controller.installPlugins"
    value = [
      "kubernetes",
      "workflow-aggregator",
      "github",
      "github-branch-source",
      "pipeline-stage-view",
      "git",
      "configuration-as-code"
    ]
  }
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