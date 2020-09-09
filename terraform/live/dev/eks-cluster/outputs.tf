output "endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_id" {
  description = "The name/id of the EKS cluster."
  value       = module.eks.cluster_id
}

//output "cluster_certificate_authority_data" {
//  description = "Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster."
//  value       = module.eks.cluster_certificate_authority_data
//}

output "worker_iam_role_arn" {
  value = module.eks.worker_iam_role_arn
}

//
//output "worker_role_cloudwatch_logs" {
//  value = aws_iam_role.worker-cloudwatch-logs.arn
//}
//
//output "kubeconfig" {
//  description = "kubectl config file contents for this EKS cluster."
//  value       = module.eks.kubeconfig
//}

