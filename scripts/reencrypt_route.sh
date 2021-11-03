#!/bin/bash
NAMESPACE=$1
kubectl -n $NAMESPACE extract secret/ibm-nginx-internal-tls-ca --keys=cert.crt --to=/tmp > /dev/null
kubectl -n $NAMESPACE delete route cpd
kubectl -n $NAMESPACE create route reencrypt cpd --service=ibm-nginx-svc --port=ibm-nginx-https-port --dest-ca-cert=/tmp/cert.crt
rm /tmp/cert.crt
