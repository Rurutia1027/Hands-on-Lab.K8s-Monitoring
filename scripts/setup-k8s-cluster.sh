#!/bin/sh 
# setup-k8s-cluster.sh

CLUSTER_NAME="k8s-cluster-monitoring-proj"
CONFIG_FILE="configs/kind-config.yaml"

echo "Creating Kind cluster: $CLUSTER_NAME ..."

kind create cluster --name "$CLUSTER_NAME" --config "$CONFIG_FILE"

echo "Kind cluster $CLUSTER_NAME created successfully!"