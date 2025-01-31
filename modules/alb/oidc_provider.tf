data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.aws_eks_cluster.cluster.identity[0].oidc[0].thumbprint]
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}