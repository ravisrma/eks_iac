cluster_name       = "eks-cluster"
instance_type      = "t2.medium"
desired_size       = 2
max_size           = 5
min_size           = 2
region             = "ap-south-1"
cluster_version    = "1.32"
vpc-cni-version    = "v1.19.2-eksbuild.1"
kube-proxy-version = "v1.31.3-eksbuild.2"
coredns-version    = "v1.11.4-eksbuild.1"
amazon_ebs_csi_driver_version = "v1.37.0-eksbuild.1"
key_name           = "test"