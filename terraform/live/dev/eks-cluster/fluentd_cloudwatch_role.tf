# Role to allow logging to cloudwatch

data "aws_iam_policy_document" "worker-cloudwatch-logs" {
  statement {
    effect = "Allow"

    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "worker-cloudwatch-logs" {
  name               = "${module.eks.cluster_id}_worker-cloudwatch-logs"
  assume_role_policy = data.aws_iam_policy_document.worker-assume-role-policy.json
}

resource "aws_iam_policy" "worker-cloudwatch-logs" {
  name_prefix = "${module.eks.cluster_id}_worker-cloudwatch-logs"
  policy      = data.aws_iam_policy_document.worker-cloudwatch-logs.json
}

resource "aws_iam_role_policy_attachment" "worker-cloudwatch-logs" {
  role       = aws_iam_role.worker-cloudwatch-logs.name
  policy_arn = aws_iam_policy.worker-cloudwatch-logs.arn
}

