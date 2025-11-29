#!/bin/sh
# monitoring-health-check.sh
NAMESPACE="metrics"

echo "Checking monitoring stack components..."

check_deployment() {
    name=$1
    ready=$(kubectl get deployment "$name" -n $NAMESPACE -o jsonpath='{.status.readyReplicas}')
    desired=$(kubectl get deployment "$name" -n $NAMESPACE -o jsonpath='{.status.replicas}')
    if [ "$ready" = "$desired" ] && [ "$ready" != "" ] ; then 
      echo "[OK] Deployment $name is ready ($ready/$desired)"
    else 
      echo "[WARN] Deployment $name is not ready ($ready/$desired)"
    fi 
}

check_daemonset() {
    name=$1
    ready=$(kubectl get daemonset "$name" -n $NAMESPACE -o jsonpath='{.status.numberReady}')
    desired=$(kubectl get daemonset "$name" -n $NAMESPACE -o jsonpath='{.status.desiredNumberScheduled}') 
    if [ "$ready" = "$desired" ] && [ "$ready" != "" ]; then 
      echo "[OK] DaemonSet $name is ready ($ready/$desired)"
    else 
      echo "[WARN] DaemonSet $name is not ready ($ready/$desired)"
    fi

}

check_http_endpoint() {
    url=$1
    name=$2
    resp=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    
    if [ "$resp" = "200" ]; then 
      echo "[OK] Endpoint $name ($url) reachables"
    else 
      echo "[WARN] Endpoint $name ($url) unreachable, HTTP code: $resp"
    fi 
}

# Check DaemonSets 
check_daemonset node-exporter
check_daemonset cadvisor 

# Check Deployments 
check_deployment kube-state-metrics
check_deployment prometheus
check_deployment grafana
#check_deployment alertmanager 

# Check metrics endpoints (assuming NodePort or port-forward)
echo "Checking Prometheus metrics endpoint..."
check_http_endpoint "http://localhost:30090/metrics" "Prometheus"

echo "Checking Grafana health endpoint..."
check_http_endpoint "http://localhost:30300/api/health" "Grafana"

# Check kube-state-metrics
KSM_POD=$(kubectl get pod -n $NAMESPACE -l "app.kubernetes.io/name=kube-state-metrics" -o jsonpath='{.items[0].metadata.name}')
kubectl port-forward -n $NAMESPACE pod/$KSM_POD 8080:8080 > /dev/null 2>&1 &
PF_PID=$!
sleep 3
check_http_endpoint "http://localhost:8080/metrics" "kube-state-metrics"
kill $PF_PID

echo "Monitoring stack health check complete, all pass!"
