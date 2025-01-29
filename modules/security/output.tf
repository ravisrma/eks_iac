# EKS Security Group ID
# output "eks_security_group_id" {
#     value = aws_security_group.eks_security_group.id
# }
output "eks_cluster_sg_id" {
    value = aws_security_group.eks_cluster_sg.id
}
output "eks_nodes_sg_id" {
    value = aws_security_group.eks_nodes_sg.id
}