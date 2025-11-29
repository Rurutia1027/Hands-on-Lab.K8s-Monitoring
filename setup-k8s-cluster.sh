#!/bin/sh
# setup-k8s-cluster.sh (CI-ready + readiness checks)
set -euo pipefail

CLUSTER_NAME="k8s-cluster"
NAMESPACE="metrics"
WAIT_TIMEOUT="300s"   # 5 min (CI-Friendly)
CHECK_INTERVAL=5

# ================================
# Utility: Wait for Deployment Ready
# ================================
wait_for_deployment() {
  DEPLOY=$1
  echo "[WAIT] Deployment/$DEPLOY in $NAMESPACE ..."

  kubectl rollout status deploy/"$DEPLOY" -n "$NAMESPACE" --timeout="$WAIT_TIMEOUT"
}

# ================================
# Utility: Wait for Pod Ready
# ================================
wait_for_pods() {
  SELECTOR=$1

  echo "[WAIT] Pods with selector: $SELECTOR ..."
  kubectl wait --for=condition=Ready pod -l "$SELECTOR" -n "$NAMESPACE" --timeout="$WAIT_TIMEOUT"
}

# ================================
# Utility: Wait for Service Endpoint
# ================================
wait_for_service_endpoints() {
  SVC=$1

  echo "[WAIT] Endpoints/$SVC in $NAMESPACE ..."
  for _ in $(seq 1 60); do
    COUNT=$(kubectl get endpoints "$SVC" -n "$NAMESPACE" -o jsonpath='{.subsets[*].addresses[*].ip}' | wc -w)
    if [ "$COUNT" -gt 0 ]; then
      echo "[OK] Endpoints available: $COUNT"
      return 0
    fi
    echo "[WAIT] Endpoints not ready, retrying..."
    sleep $CHECK_INTERVAL
  done

  echo "[ERROR] Service $SVC endpoint NOT ready"
  exit 1
}

# ================================
# Utility: HTTP Readiness Check
# Requires curl
# ================================
check_http_ready() {
  NAME=$1
  URL=$2

  echo "[CHECK] Checking HTTP endpoint for $NAME: $URL"

  for _ in $(seq 1 30); do
    if curl -sf "$URL" >/dev/null 2>&1; then
      echo "[OK] $NAME is reachable."
      return 0
    fi
    echo "[WAIT] $NAME endpoint not ready, retrying..."
    sleep $CHECK_INTERVAL
  done

  echo "[ERROR] $NAME endpoint NOT reachable"
  exit 1
}

echo "====================================================="
echo "[1] Wait for all K8s nodes Ready"
echo "====================================================="
kubectl wait --for=condition=Ready node --all --timeout="$WAIT_TIMEOUT"

echo "Nodes:"
kubectl get nodes -o wide

echo "====================================================="
echo "[2] Prepare namespace and Helm repos"
echo "====================================================="
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

echo "====================================================="
echo "[3] Install Kube-State-Metrics"
echo "====================================================="
helm upgrade --install kube-state-metrics prometheus-community/kube-state-metrics \
  -n "$NAMESPACE" \
  --set rbac.create=true \
  --set replicaCount=1 \
  --set service.type=ClusterIP

wait_for_deployment kube-state-metrics

echo "====================================================="
echo "[4] Install Prometheus"
echo "====================================================="
helm upgrade --install prometheus prometheus-community/prometheus \
  -n "$NAMESPACE" \
  -f helm/prometheus-values.yaml

wait_for_deployment prometheus-server
wait_for_service_endpoints prometheus-server

echo "====================================================="
echo "[5] Install Grafana"
echo "====================================================="
helm upgrade --install grafana grafana/grafana \
  -n "$NAMESPACE" \
  -f helm/grafana-values.yaml

wait_for_deployment grafana
wait_for_service_endpoints grafana

echo "====================================================="
echo "[6] Verify HTTP endpoints (via temp port-forward)"
echo "====================================================="
# Prometheus
kubectl port-forward -n "$NAMESPACE" svc/prometheus-server 9090:80 >/tmp/prom_pf.log 2>&1 &
PROM_PF_PID=$!
sleep 3
check_http_ready "Prometheus" "http://localhost:9090/-/ready"
kill $PROM_PF_PID || true

# Grafana
kubectl port-forward -n "$NAMESPACE" svc/grafana 3000:3000 >/tmp/grafana_pf.log 2>&1 &
GRAFANA_PF_PID=$!
sleep 3
check_http_ready "Grafana" "http://localhost:3000"
kill $GRAFANA_PF_PID || true

echo "====================================================="
echo "[OK] All components deployed and verified!"
echo "====================================================="
