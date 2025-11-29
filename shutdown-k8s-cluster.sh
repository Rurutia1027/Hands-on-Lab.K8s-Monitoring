#!/bin/sh
# shutdown-k8s-cluster.sh

kind get clusters 
kind delete cluster --name k8s-cluster