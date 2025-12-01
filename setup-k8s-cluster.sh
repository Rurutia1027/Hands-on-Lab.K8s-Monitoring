#!/bin/sh
# setup-k8s-cluster.sh
# Refined version: focus on Prometheus, Grafana, and Loki

CLUSTER_NAME="k8s-cluster"
CONFIG_FILE="configs/kind-config.yaml"
NAMESPACE="metrics"

# Source shell profile to include Helm in PATH
if [ -f "$HOME/.bash_profile" ]; then
    source "$HOME/.bash_profile"
fi

echo "====================================================="
echo "[1] Creating Kind cluster (if not already exists)"
echo "====================================================="
if ! kind get clusters | grep -q "$CLUSTER_NAME"; then 
    kind create cluster --name "$CLUSTER_NAME" --config "$CONFIG_FILE"
else 
    echo "[INFO] Kind cluster '$CLUSTER_NAME' already exists. Skipping creation."
fi 

echo "====================================================="
echo "[2] Waiting for all nodes to be Ready..."
echo "====================================================="
kubectl wait --for=condition=Ready nodes --all --timeout=180s

echo "[INFO] Node status:"
kubectl get nodes -o wide
kubectl get pods -A

echo "====================================================="
echo "[3] Setting up namespace and Helm repositories"
echo "====================================================="
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
echo "[INFO] Helm repositories updated"

echo "====================================================="
echo "[4] Installing Prometheus via Helm"
echo "====================================================="
helm upgrade --install prometheus prometheus-community/prometheus \
  -n "$NAMESPACE" \
  --create-namespace \
  -f helm/prometheus-values.yaml

echo "[INFO] Prometheus pods:"
kubectl get pods -n "$NAMESPACE"

echo "[INFO] Prometheus services:"
kubectl get svc -n "$NAMESPACE"

echo "====================================================="
echo "[5] Installing Grafana via Helm"
echo "====================================================="
helm upgrade --install grafana grafana/grafana \
  -n "$NAMESPACE" \
  --create-namespace \
  -f helm/grafana-values.yaml

echo "[INFO] Grafana pods:"
kubectl get pods -n "$NAMESPACE"

echo "[INFO] Grafana services:"
kubectl get svc -n "$NAMESPACE"

echo "[INFO] Current Helm releases in namespace '$NAMESPACE':"
helm list -n "$NAMESPACE"

echo "====================================================="
echo "[INFO] Installing Loki stack (logs aggregation)"
echo "====================================================="
helm install loki grafana/loki-stack --namespace $NAMESPACE
kubectl get pods -n $NAMESPACE

echo "====================================================="
echo "[INFO] Setup completed successfully!"
echo "[INFO] Access Prometheus and Grafana via NodePort / ClusterIP as configured."
echo "-----------------------------------------------------"
echo "Prometheus:"
echo "  kubectl port-forward -n $NAMESPACE svc/prometheus 9090:9090"
echo "  Browser URL: http://localhost:9090"
echo "Grafana:"
echo "  kubectl port-forward -n $NAMESPACE svc/grafana 3000:3000"
echo "  Browser URL: http://localhost:3000"

echo "-----------------------------------------------------"
echo "[TIP] Optional: run port-forward in background with & to keep it active"
echo "Example:"
echo "  kubectl port-forward svc/prometheus-server -n $NAMESPACE 9090:80 &"
echo "  kubectl port-forward -n $NAMESPACE svc/grafana 3000:3000 &"

echo "====================================================="
echo "[INFO] Full stack ready: Prometheus + Grafana + Loki"
echo "====================================================="
helm list -n "$NAMESPACE"