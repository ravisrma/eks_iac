
# Creating EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = var.master_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = [var.public_subnet_az1_id, var.public_subnet_az2_id]
    security_group_ids     = [var.eks_cluster_sg_id]
  
  }
  tags = {
    Name = var.cluster_name
  }
}
# Create a launch template for the worker nodes
resource "aws_launch_template" "eks_launch_template" {
  name_prefix   = "eks-launch-template-"
  image_id      = "ami-0de390ef01354cadf"  # Replace with the latest Amazon EKS optimized AMI for your region
  instance_type = var.instance_type              # Specify your desired instance type
  vpc_security_group_ids = [var.eks_nodes_sg_id]

  key_name = var.key_name

  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -o xtrace
              /etc/eks/bootstrap.sh eks-cluster
              EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "EKS-Node-${aws_eks_cluster.eks.name}"
    }
  }
}
# Create the EKS node group using the launch template
resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "my-node-group"
  node_role_arn   = var.worker_arn
  subnet_ids      = [var.public_subnet_az1_id, var.public_subnet_az2_id]

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }


  launch_template {
    id      = aws_launch_template.eks_launch_template.id
    version = "$Latest"  # Use the latest version of the launch template
  }

  tags = {
    Name        = "EKS-NodeGroup-${aws_eks_cluster.eks.name}"
  }

  depends_on = [aws_eks_cluster.eks]
}


# # EKS Node Groups
# resource "aws_eks_node_group" "this" {
#   cluster_name    = aws_eks_cluster.eks.name
#   node_group_name = "Worker-Node-Group"
#   node_role_arn   = var.worker_arn
#   subnet_ids      = [var.public_subnet_az1_id, var.public_subnet_az2_id]


#   scaling_config {
#     desired_size = var.desired_size
#     max_size     = var.max_size
#     min_size     = var.min_size
#   }

#   remote_access {
#     ec2_ssh_key = var.key_name
#   }
#   ami_type       = "AL2_x86_64" # AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM
#   capacity_type  = "ON_DEMAND"  # ON_DEMAND, SPOT
#   disk_size      = 20
#   instance_types = [var.instance_size]
  

# }




locals {
  eks_addons = {
    "vpc-cni" = {
      version           = var.vpc-cni-version
      resolve_conflicts = "OVERWRITE"
    },
    "kube-proxy" = {
      version           = var.kube-proxy-version
      resolve_conflicts = "OVERWRITE"
    },
    "coredns" = {
      version           = var.coredns-version
      resolve_conflicts = "OVERWRITE"
    },
    "aws-ebs-csi-driver" = {
      version           = var.amazon_ebs_csi_driver_version
      resolve_conflicts = "OVERWRITE"
    }
  }
}

resource "aws_eks_addon" "example" {
  for_each = local.eks_addons

  cluster_name                = aws_eks_cluster.eks.name
  addon_name                  = each.key
  addon_version               = each.value.version
  resolve_conflicts_on_update = each.value.resolve_conflicts

}