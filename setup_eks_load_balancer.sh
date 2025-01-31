#!/bin/bash

# Step 1: Fetch the IAM policy for your ALB
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json

# Step 2: Create the IAM policy in your AWS account
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json

# Step 3: Associate IAM OIDC provider with your EKS cluster
eksctl utils associate-iam-oidc-provider --region=ap-south-1 --cluster=eks-cluster --approve

# Step 4: Create and attach a service account to your cluster
# Replace <your-aws-account-id> with your actual AWS account ID
aws_account_id=522814736852
eksctl create iamserviceaccount --cluster=eks-cluster --namespace=kube-system --name=aws-load-balancer-controller --role-name AmazonEKSLoadBalancerControllerRole --attach-policy-arn=arn:aws:iam::$aws_account_id:policy/AWSLoadBalancerControllerIAMPolicy --approve --region=ap-south-1

# Step 5: Install Helm
sudo snap install helm --classic

# Step 6: Add EKS Helm repo
helm repo add eks https://aws.github.io/eks-charts

# Step 7: Update the EKS Helm repo
helm repo update eks

# Step 8: Install the load balancer controller on your EKS cluster
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=eks-cluster --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller

# Verify the deployment
kubectl get deployment -n kube-system aws-load-balancer-controller