#!/bin/bash
set -e

echo "======================================"
echo "Authenticating with EKS"
echo "======================================"

AWS_REGION="ap-south-1"
EKS_CLUSTER_NAME="speshway-test-eks"

echo "AWS Region: ${AWS_REGION}"
echo "EKS Cluster: ${EKS_CLUSTER_NAME}"

echo "======================================"
echo "Updating kubeconfig"
echo "======================================"

aws eks update-kubeconfig \
    --region "${AWS_REGION}" \
    --name "${EKS_CLUSTER_NAME}"

echo "======================================"
echo "Testing Kubernetes Access"
echo "======================================"

kubectl get nodes

echo "======================================"
echo "EKS Authentication Completed"
echo "======================================"
