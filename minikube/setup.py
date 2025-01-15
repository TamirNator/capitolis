import subprocess

def run_command(command):
    try:
        print(f"Running: {command}")
        subprocess.run(command, shell=True, check=True, text=True)
    except subprocess.CalledProcessError as e:
        print(f"Command failed: {e}")
        raise

def start_minikube():
    run_command("minikube start --driver=docker")

def deploy_jenkins():
    run_command("""
    helm repo add jenkins https://charts.jenkins.io
    helm repo update
    helm upgrade --install jenkins jenkins/jenkins \
        --namespace default \
        --set controller.service.type=LoadBalancer \
        --set controller.admin.user=admin \
        --set controller.admin.password=admin \
        --set controller.service.port=8080
    """)

def deploy_registry():
    run_command("""
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update
    helm upgrade --install docker-registry stable/docker-registry \
        --namespace default \
        --set service.type=LoadBalancer \
        --set service.port=5000 \
        --set persistence.enabled=true \
        --set persistence.size=1Gi \
        --set persistence.storageClass="standard"
    """)

# def deploy_application():
#     run_command("""
#     helm upgrade --install my-app ./my-app-chart --namespace default \
#         --set service.type=LoadBalancer \
#         --set service.port=80 \
#         --set service.targetPort=8080
#     """)

def main():
    start_minikube()
    deploy_jenkins()
    deploy_registry()
    #deploy_application()
    print("Run 'minikube tunnel' to expose the LoadBalancer services.")

if __name__ == "__main__":
    main()