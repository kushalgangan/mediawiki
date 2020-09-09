data "aws_iam_policy_document" "worker-assume-role-policy" {
  statement {
    principals {
      identifiers = [module.eks.worker_iam_role_arn]
      type        = "AWS"
    }

    actions = ["sts:AssumeRole"]
  }
}

