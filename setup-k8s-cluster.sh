#!/bin/sh
# setup-k8s-cluster.sh
# Refined version: focus on Kube-State-Metrics, Prometheus, Grafana
set -euo pipefail

CLUSTER_NAME="k8s-cluster"
CONFIG_FILE="configs/kind-config.yaml"
NAMESPACE="metrics"

# Source shell profile to include Helm in PATH
if [ -f "$HOME/.bash_profile" ]; then
    source "$HOME/.bash_profile"
fi

echo "====================================================="
echo "[1] Create Kind cluster (if not exists)"
echo "====================================================="
if ! kind get clusters | grep -q "$CLUSTER_NAME"; then 
    kind create cluster --name "$CLUSTER_NAME" --config "$CONFIG_FILE"
else 
    echo "Kind cluster '$CLUSTER_NAME' already exists. Skipping creation."
fi 

echo "====================================================="
echo "[2] Wait for all nodes to be Ready"
echo "====================================================="
kubectl wait --for=condition=Ready nodes --all --timeout=180s

echo "[INFO] Node status:"
kubectl get nodes -o wide
kubectl get pods -A

echo "====================================================="
echo "[3] Prepare namespace and Helm repos"
echo "====================================================="
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

echo "====================================================="
echo "[4] Install Kube-State-Metrics via Helm"
echo "====================================================="
helm upgrade --install kube-state-metrics prometheus-community/kube-state-metrics \
  -n "$NAMESPACE" \
  --create-namespace \
  --set rbac.create=true \
  --set replicaCount=1 \
  --set service.type=ClusterIP

echo "====================================================="
echo "[INFO] KSM pods status:"
echo "====================================================="
kubectl get pods -n "$NAMESPACE"

echo "====================================================="
echo "[INFO] Helm releases in '$NAMESPACE' namespace:"
echo "====================================================="
helm list -n "$NAMESPACE"

echo "====================================================="
echo "[5] Install Prometheus via Helm"
echo "====================================================="
helm upgrade --install prometheus prometheus-community/prometheus \
  -n "$NAMESPACE" \
  --create-namespace \
  -f helm/prometheus-values.yaml

echo "====================================================="
echo "[INFO] Prometheus pods status:"
echo "====================================================="
kubectl get pods -n "$NAMESPACE"

echo "====================================================="
echo "[INFO] Prometheus services:"
echo "====================================================="
kubectl get svc -n "$NAMESPACE"

echo "====================================================="
echo "[6] Install Grafana via Helm"
echo "====================================================="
helm upgrade --install grafana grafana/grafana \
  -n "$NAMESPACE" \
  --create-namespace \
  -f helm/grafana-values.yaml

echo "====================================================="
echo "[INFO] Grafana pods status:"
echo "====================================================="
kubectl get pods -n "$NAMESPACE"

echo "====================================================="
echo "[INFO] Grafana services:"
echo "====================================================="
kubectl get svc -n "$NAMESPACE"

echo "====================================================="
echo "[INFO] Helm releases summary:"
echo "====================================================="
helm list -n "$NAMESPACE"

echo "====================================================="
echo "[INFO] Setup completed successfully!"
echo "Access Prometheus NodePort / ClusterIP and Grafana NodePort as configured."
echo "====================================================="

echo "====================================================="
echo "[INFO] Port-forwarding Prometheus and Grafana for local access"
echo "====================================================="

# Prometheus port-forward
echo "Prometheus:"
echo "  kubectl port-forward -n $NAMESPACE svc/prometheus 9090:9090"
echo "  Access in browser: http://localhost:9090"

# Grafana port-forward
echo "Grafana:"
echo "  kubectl port-forward -n $NAMESPACE svc/grafana 3000:3000"
echo "  Access in browser: http://localhost:3000"

echo "====================================================="
echo "[INFO] Optional: run port-forwarding in background with & if you want to keep it active"
echo "Example:"
echo "  kubectl port-forward svc/prometheus-server -n metrics 9090:80 &"
echo "  kubectl port-forward -n metrics svc/grafana 3000:3000 &"

echo "====================================================="
echo "[INFO] Setup completed successfully! Prometheus + Grafana + KSM are ready."
echo "====================================================="
