resource "helm_release" "jenkins" {
  name       = "jenkins"
  chart      = "jenkins"
  repository = "https://charts.jenkins.io"
  namespace  = "jenkins"
  create_namespace = true
  values          = [file("${path.module}/manifests/jenkins-values.yaml")]
  depends_on = [ module.eks ]
}

output "name" {
  value = helm_release.nginx_ingress
  sensitive = true
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Cluster"
  }

  set {
    name  = "controller.replicaCount"
    value = 2
  }

  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }
}

# Grafana Helm Release
resource "helm_release" "grafana" {
  name            = "grafana"
  chart           = "grafana"
  repository      = "https://grafana.github.io/helm-charts"
  namespace       = "monitoring"
  create_namespace = true

  values = [file("${path.module}/manifests/grafana-values.yaml")]

  depends_on = [module.eks]
}

# Prometheus Helm Release
resource "helm_release" "prometheus" {
  name            = "kube-prometheus-stack"
  chart           = "kube-prometheus-stack"
  repository      = "https://prometheus-community.github.io/helm-charts"
  namespace       = "monitoring"

  values = [file("${path.module}/manifests/prometheus-values.yaml")]

  depends_on = [module.eks, helm_release.grafana]
}