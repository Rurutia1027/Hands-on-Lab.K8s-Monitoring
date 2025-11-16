#!/bin/sh 
# setup-k8s-cluster.sh

# Create Cluster 
CLUSTER_NAME="k8s-cluster-monitoring-proj"
CONFIG_FILE="configs/kind-config.yaml"

echo "Creating Kind cluster: $CLUSTER_NAME ..."

kind create cluster --name "$CLUSTER_NAME" --config "$CONFIG_FILE"

echo "Kind cluster $CLUSTER_NAME created successfully!"

# Create monitoring namespace 

kubectl apply -f manifests/namespace.yaml 

# Generate etcd certs & secret 

./generate-etcd-certs.sh 


# Deploy monitoring stack 

cd ../ # jump to main path 

# setup Node Exporter 

# setup cAdvisor 

# setup kube-state-metrics

# setup prometheus 

# setup grafana 

