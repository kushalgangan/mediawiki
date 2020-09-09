variable "k8s_cluster_whitelist_ips" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}