#!/bin/sh
# setup-k8s-cluster.sh
set -e

CLUSTER_NAME="k8s-cluster-monitoring-proj"
CONFIG_FILE="scripts/configs/kind-config.yaml"

echo "[1] Creating Kind cluster: $CLUSTER_NAME ..."
kind create cluster --name "$CLUSTER_NAME" --config "$CONFIG_FILE"

echo "[2] Waiting for nodes to be Ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=180s

kubectl get nodes
kubectl get pods -A

echo "Kind cluster '$CLUSTER_NAME' created successfully!"
