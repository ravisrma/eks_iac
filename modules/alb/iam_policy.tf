resource "aws_iam_policy" "alb_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "IAM policy for ALB Controller"

  policy = file("${path.module}/iam_policy.json")
}