module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "otel-vpc"

  cidr = "10.0.0.0/16"

  azs = [
    "us-east-2a",
    "us-east-2b"
  ]

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
  map_public_ip_on_launch = true

  enable_nat_gateway = false
  single_nat_gateway = false

  tags = {
    Environment = "dev"
    Project     = "otel-demo"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.15.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  cluster_endpoint_public_access = true

  vpc_id = module.vpc.vpc_id

  subnet_ids = module.vpc.public_subnets

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    default = {
      instance_types = ["m7i-flex.large"]

      min_size     = 1
      max_size     = 1
      desired_size = 1

      disk_size = 40

      ami_type = "AL2023_x86_64_STANDARD"

      capacity_type = "ON_DEMAND"
    }
  }

  tags = {
    Project = "otel-demo"
  }
}
