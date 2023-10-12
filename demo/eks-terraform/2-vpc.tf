data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = var.eks_cluster_name
  cidr = "10.0.0.0/16"

  # azs             = ["us-east-2a", "us-east-2b"]
  # private_subnets = ["10.0.0.0/19", "10.0.32.0/19"]
  # public_subnets  = ["10.0.64.0/19", "10.0.96.0/19"]

  azs  = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = ["10.0.10.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  public_subnets  = ["10.0.14.0/24", "10.0.15.0/24", "10.0.16.0/24"]
  
  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  # Required for public EKS nodes. 
  map_public_ip_on_launch = true

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"               = 1
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb"                        = 1
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}
