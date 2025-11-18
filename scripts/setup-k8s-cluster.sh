#!/bin/sh
# setup-k8s-cluster.sh
set -e

CLUSTER_NAME="k8s-cluster-monitoring-proj"
CONFIG_FILE="configs/kind-config.yaml"

echo "[1] Creating Kind cluster: $CLUSTER_NAME ..."
kind create cluster --name "$CLUSTER_NAME" --config "$CONFIG_FILE"

echo "[2] Waiting for nodes to be Ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=180s

kubectl get nodes
kubectl get pods -A

echo "Kind cluster '$CLUSTER_NAME' created successfully!"

cd ../ 

############################################
# Create monitoring namespace
############################################
echo "[3] Creating 'monitoring' namespace..."
kubectl apply -f manifests/namespace.yaml

############################################
# Deploy metrics collectors
############################################
echo "[4] Deploying Node Exporter..."
kubectl apply -f manifests/node-exporter/daemonset.yaml
kubectl apply -f manifests/node-exporter/service.yaml

echo "[5] Deploying cAdvisor..."
kubectl apply -f manifests/cadvisor/daemonset.yaml
kubectl apply -f manifests/cadvisor/service.yaml

echo "[6] Deploying kube-state-metrics..."
kubectl apply -f manifests/kube-state-metrics/rbac.yaml
kubectl apply -f manifests/kube-state-metrics/deployment.yaml
kubectl apply -f manifests/kube-state-metrics/service.yaml

############################################
# Deploy Prometheus
############################################
echo "[7] Deploying Prometheus..."
kubectl apply -f manifests/prometheus/rbac.yaml
kubectl apply -f manifests/prometheus/pvc.yaml
kubectl apply -f manifests/prometheus/configmap.yaml
kubectl apply -f manifests/prometheus/deployment.yaml
kubectl apply -f manifests/prometheus/service.yaml

############################################
# Deploy Grafana
############################################
echo "[8] Deploying Grafana..."
kubectl apply -f manifests/grafana/rbac.yaml
kubectl apply -f manifests/grafana/pvc.yaml
kubectl apply -f manifests/grafana/deployment.yaml
kubectl apply -f manifests/grafana/service.yaml

############################################
# Health Checks
############################################
echo "[9] Running health check scripts..."
bash scripts/k8s-cluster-health.sh
bash scripts/monitoring-health-check.sh

############################################
# Port-forwarding (non-blocking recommendation)
############################################
echo "[10] Cluster setup completed!"
echo "To access UIs, run in separate terminals:"
echo "  kubectl -n monitoring port-forward svc/prometheus 9090:9090"
echo "  kubectl -n monitoring port-forward svc/grafana 3000:3000"
