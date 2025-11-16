#!/bin/sh 
set -e 

NAMESPACE="monitoring"
SECRET_NAME="etcd-certs"
CERT_DIR="./certs"

mkdir -p $CERT_DIR

# Generate self-signed certs (for dev/local cluster)
openssl genrsa -out $CERT_DIR/client.key 2048
openssl req -new -key $CERT_DIR/client.key -subj "/CN=etcd-client" -out $CERT_DIR/client.csr
openssl x509 -req -in $CERT_DIR/client.csr -signkey $CERT_DIR/client.key -out $CERT_DIR/client.crt -days 365

cp /var/run/secrets/kubernetes.io/serviceaccount/ca.crt $CERT_DIR/ca.crt 

kubectl -n $NAMESPACE delete secret $SECRET_NAME --ignore-not-found
kubectl -n $NAMESPACE create secret generic $SECRET_NAME \
  --from-file=ca.crt=$CERT_DIR/ca.crt \
  --from-file=client.crt=$CERT_DIR/cleint.crt \
  --from-file=client.key=$CERT_DIR/client.key 


echo "Etcd certificates and Kubernetes secret created."