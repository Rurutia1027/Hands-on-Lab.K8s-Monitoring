#!/bin/sh 
# k8s-cluster-health.sh
# Check Kind Setup Kubernetes core components status 

echo "Checking Kubernetes cluster core components ..."

COMPONENTS="kube-apiserver kube-controller-manager kube-scheduler etcd kube-proxy"
NAMESPACE="kube-system"
all_ready=true 

for comp in $COMPONENTS; do
  pods=$(kubectl get pods -n $NAMESPACE -l component=$comp -o jsonpath='{.items[*].metadata.name}')
  for pod in $pods; do 
    status=$(kubectl get pod "$pod" -n $NAMESPACE -o jsonpath='{.status.phase}')
    ready=$(kubectl get pod "$pod" -n $NAMESPACE -o jsonpath='{.status.containerStatuses[0].ready}')
    if [ "$status" = "Running" ] && [ "$ready" = "true" ]; then 
      echo "[OK] $pod ($comp) is running and ready"
    else 
      echo "[WARN] $pod ($comp) is not ready"
      all_ready=false 
    fi 
  done
done 

if [ "$all_ready" = true ]; then 
  echo "All core Kubernetes components are ready!"
else 
  echo "Some core components are not ready!"
fi 