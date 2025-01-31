terraform {
  backend "s3" {
    bucket         = "eks-terraform-bucket0"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
  }
}
# Creating VPC
module "vpc" {
  source       = "./modules/vpc"
  cluster_name = var.cluster_name
}

#Creating security group
module "security_groups" {
  source       = "./modules/security"
  vpc_id       = module.vpc.vpc_id
  cluster_name = var.cluster_name
} 

# }
# Creating IAM resources
module "iam" {
  source = "./modules/iam"
}



# Creating EKS Cluster
module "eks" {
  source = "./modules/eks"
  master_arn = module.iam.master_arn
  worker_arn = module.iam.worker_arn
  instance_type = var.instance_type
  desired_size = var.desired_size
  max_size = var.max_size
  min_size = var.min_size
  cluster_name = var.cluster_name
  cluster_version = var.cluster_version
  public_subnet_az1_id = module.vpc.public_subnet_az1_id
  public_subnet_az2_id = module.vpc.public_subnet_az2_id
  eks_cluster_sg_id = module.security_groups.eks_cluster_sg_id
  eks_nodes_sg_id = module.security_groups.eks_nodes_sg_id
  vpc_id = module.vpc.vpc_id
  key_name = var.key_name
  amazon_ebs_csi_driver_version = var.amazon_ebs_csi_driver_version
  vpc-cni-version = var.vpc-cni-version
  kube-proxy-version = var.kube-proxy-version
  coredns-version = var.coredns-version
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "alb" {
  source              = "./modules/alb"
  cluster_name        = var.cluster_name
  vpc_id              = var.vpc_id
  public_subnet_az1_id = var.public_subnet_az1_id
  public_subnet_az2_id = var.public_subnet_az2_id
  alb_security_group_id = var.alb_security_group_id
}