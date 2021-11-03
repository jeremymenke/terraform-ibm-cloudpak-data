#!/bin/bash

kubectl project ${OP_NAMESPACE}

## Install Operator

cd ../files

sed -i -e "s/OPERATOR_NAMESPACE/${OP_NAMESPACE}/g" dv-sub.yaml

echo '*** executing **** kubectl create -f dv-sub.yaml'
result=$(kubectl create -f dv-sub.yaml)
echo $result
sleep 1m

cd ../scripts

# Checking if the dv operator pods are ready and running.

./pod-status-check.sh ibm-dv-operator ${OP_NAMESPACE}

# switch to zen namespace
kubectl project ${NAMESPACE}

# # Install dv Customer Resource

cd ../files

sed -i -e "s/REPLACE_NAMESPACE/${NAMESPACE}/g" dv-cr.yaml
echo '*** executing **** kubectl create -f dv-cr.yaml'
result=$(kubectl create -f dv-cr.yaml)
echo $result

#patch for dmc issue
# sleep 12m
# kubectl patch -n ibm-common-services sub ibm-dmc-operator --type=merge --patch='{"spec": {"source": "ibm-operator-catalog"}}'

cd ../scripts

# check the dv cr status
./check-cr-status.sh dvservice dv-service ${NAMESPACE} reconcileStatus
