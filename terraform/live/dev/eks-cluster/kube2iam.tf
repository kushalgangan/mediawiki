//# Terraform to support kube2iam : https://github.com/jtblin/kube2iam#iam-roles
//
//data "aws_iam_policy_document" "assume_role" {
//  statement {
//    effect = "Allow"
//
//    actions = [
//      "sts:AssumeRole",
//    ]
//
//    resources = [
//      "*",
//    ]
//  }
//}
//
//resource "aws_iam_policy" "workers_assume_role" {
//  name        = "${module.eks.cluster_id}_workers_assume_role"
//  description = "Allow EKS workers to assume IAM roles"
//  policy      = data.aws_iam_policy_document.assume_role.json
//}
//
//resource "aws_iam_role_policy_attachment" "workers_assume_role" {
//  policy_arn = aws_iam_policy.workers_assume_role.arn
//  role       = module.eks.worker_iam_role_name
//}

data "aws_iam_policy_document" "worker-assume-role-policy" {
  statement {
    principals {
      identifiers = [module.eks.worker_iam_role_arn]
      type        = "AWS"
    }

    actions = ["sts:AssumeRole"]
  }
}

