provider "aws" {
  region              = var.region
  profile             = var.aws_profile != "" ? var.aws_profile : null
  allowed_account_ids = [var.expected_account_id]
}

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

locals {
  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
    ebs-csi    = {}
  }

  effective_github_deploy_role_arn = var.github_deploy_role_arn != "" ? var.github_deploy_role_arn : (
    var.create_github_actions_oidc_resources ? aws_iam_role.github_actions_deploy[0].arn : ""
  )
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  count = var.create_github_actions_oidc_resources ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [var.github_oidc_thumbprint]
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  count = var.create_github_actions_oidc_resources ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions[0].arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [var.github_repository_subject]
    }
  }
}

resource "aws_iam_role" "github_actions_deploy" {
  count = var.create_github_actions_oidc_resources ? 1 : 0

  name               = var.github_actions_deploy_role_name
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role[0].json
}

resource "aws_iam_role_policy_attachment" "github_actions_deploy_admin" {
  count = var.create_github_actions_oidc_resources && var.attach_admin_policy_to_github_deploy_role ? 1 : 0

  role       = aws_iam_role.github_actions_deploy[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs                    = var.azs
  private_subnets        = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets         = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.2"

  cluster_name                             = var.cluster_name
  cluster_version                          = "1.30"
  vpc_id                                   = module.vpc.vpc_id
  subnet_ids                               = module.vpc.private_subnets
  cluster_endpoint_public_access           = true
  cluster_endpoint_private_access          = true
  enable_cluster_creator_admin_permissions = true
  cluster_enabled_log_types                = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  create_cloudwatch_log_group              = true
  cloudwatch_log_group_retention_in_days   = 30
  create_kms_key                           = true

  cluster_addons = local.cluster_addons

  node_security_group_additional_rules = {
    ingress_all_from_cluster = {
      description                   = "Allow cluster to reach nodes"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  eks_managed_node_groups = {
    default = {
      name           = "${var.cluster_name}-default"
      instance_types = ["t3.large"]
      capacity_type  = "ON_DEMAND"
      min_size       = 2
      max_size       = 6
      desired_size   = 3
      labels = {
        workload = "redemption"
      }
    }
  }
}

module "aws_load_balancer_controller_irsa" {
  count   = var.enable_alb_controller ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.52.2"

  role_name = "${var.cluster_name}-aws-load-balancer-controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "kubernetes_service_account" "aws_load_balancer_controller" {
  count = var.enable_alb_controller ? 1 : 0

  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.aws_load_balancer_controller_irsa[0].iam_role_arn
    }
    labels = {
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
  }

  depends_on = [module.eks, module.aws_load_balancer_controller_irsa]
}

resource "helm_release" "aws_load_balancer_controller" {
  count      = var.enable_alb_controller ? 1 : 0
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.11.0"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.aws_load_balancer_controller[0].metadata[0].name
  }

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }

  depends_on = [kubernetes_service_account.aws_load_balancer_controller]
}

resource "aws_eks_access_entry" "github_deploy" {
  count = local.effective_github_deploy_role_arn != "" ? 1 : 0

  cluster_name  = module.eks.cluster_name
  principal_arn = local.effective_github_deploy_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_deploy_admin" {
  count = local.effective_github_deploy_role_arn != "" ? 1 : 0

  cluster_name  = module.eks.cluster_name
  principal_arn = local.effective_github_deploy_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.github_deploy]
}
