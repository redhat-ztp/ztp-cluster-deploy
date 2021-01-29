#!/usr/bin/env bash

CLUSTER_NAME=$1
KUBE_CONFIG=$2

cat << EOF >> ./import-$CLUSTER_NAME.yaml
apiVersion: cluster.open-cluster-management.io/v1
kind: ManagedCluster
metadata:
  labels:
    cloud: auto-detect
    vendor: auto-detect
    name: $CLUSTER_NAME
  name: $CLUSTER_NAME
spec:
  hubAcceptsClient: true
---
apiVersion: agent.open-cluster-management.io/v1
kind: KlusterletAddonConfig
metadata:
  name: $CLUSTER_NAME
  namespace: $CLUSTER_NAME
spec:
  clusterName: $CLUSTER_NAME
  clusterNamespace: $CLUSTER_NAME
  clusterLabels:
    cloud: auto-detect
    vendor: auto-detect
  applicationManager:
    enabled: true
  policyController:
    enabled: true
  searchCollector:
    enabled: true
  certPolicyController:
    enabled: true
  iamPolicyController:
    enabled: true
  version: 2.1.0
EOF

oc --kubeconfig=$KUBE_CONFIG apply -f ./import-$CLUSTER_NAME.yaml
