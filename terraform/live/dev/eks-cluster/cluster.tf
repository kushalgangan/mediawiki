locals {
  colour       = "blue"
  environment  = "qa"
  cluster_name = "${local.colour}-kg-dev-cluster"

  workers_group_defaults = {
    root_volume_size = 30
  }

  worker_groups_launch_template = [
    {
      name = "spot-1"
      override_instance_types = [
        "m5.large",
        "m5a.large",
        "t3.large",
        "t3a.large",
        "m4.large",
        "r5.large",
        "m5.xlarge",
        "r5a.large",
        "t2.large",
      ]
      spot_price                               = "0.1"
      spot_instance_pools                      = 3
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      asg_max_size                             = 3
      asg_desired_capacity                     = 2
      instance_type                            = "m5.large"
      subnets                                  = data.aws_subnet_ids.private.ids
      kubelet_extra_args                       = "--node-labels=node.kubernetes.io/lifecycle=spot"
      suspended_processes                      = ["AZRebalance"] # A list of processes to suspend. i.e. ["AZRebalance", "HealthCheck", "ReplaceUnhealthy"]

      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "owned"
        }
      ]
    },
  ]

  kubeconfig_name = "kg-dev-${local.colour}"

  //  NAT_CIDR = list(join("/", ["${data.aws_nat_gateway.nat_ip.public_ip}", "32"]))
  //  Allowed_IP_Range = concat(var.k8s_cluster_whitelist_ips, local.NAT_CIDR)
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

module "eks" {
  source                               = "terraform-aws-modules/eks/aws"
  version                              = "12.1.0"
  cluster_name                         = local.cluster_name
  kubeconfig_name                      = local.kubeconfig_name
  cluster_version                      = "1.16"
  subnets                              = data.aws_subnet_ids.all.ids
  vpc_id                               = data.aws_vpc.kubernetes.id
  workers_group_defaults               = local.workers_group_defaults
  worker_groups_launch_template        = local.worker_groups_launch_template
  cluster_endpoint_public_access_cidrs = var.k8s_cluster_whitelist_ips
  write_kubeconfig                     = true
  //  manage_aws_auth  = false

  tags = {
    Environment = local.environment
    Deployment  = local.colour
  }
}

resource "aws_ssm_parameter" "worker_iam_role_arn" {
  name        = "${local.cluster_name}_worker_iam_role_arn"
  type        = "String"
  value       = module.eks.worker_iam_role_arn
  description = "Cluster worker role arn"
}

// The module we use for EKS can't set tags on the cluster :-(
resource "null_resource" "tag-cluster" {
  triggers = {
    // We have to run every time as there is no trigger we can rely on to detect when the tags have been removed from the cluster - aaaarrrrgggghhhh
    build_number = timestamp()
  }

  depends_on = [module.eks]

  # Tag the cluster for use later on.
  # The tag called "kg/friendly_name" is used to set the k8s context in our workstations

  provisioner "local-exec" {
    command = "aws eks tag-resource --resource-arn ${module.eks.cluster_arn} --tags kg/friendly_name=${local.kubeconfig_name}"
  }
}

data "aws_vpc" "kubernetes" {
  tags = {
    Name        = "kg-dev-vpc"
    Environment = "kg-dev"
  }
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.kubernetes.id
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.kubernetes.id

  tags = {
    Tier = "private"
  }
}

//data "aws_nat_gateway" "nat_ip" {
//  tags = {
//    Environment = "kg-dev-cluster"
//  }
//}