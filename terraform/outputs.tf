output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "ecr_repository_name" {
  value = aws_ecr_repository.redemption.name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.redemption.repository_url
}

output "aws_load_balancer_controller_role_arn" {
  value = var.enable_alb_controller ? module.aws_load_balancer_controller_irsa[0].iam_role_arn : null
}

output "github_deploy_role_access_enabled" {
  value = local.effective_github_deploy_role_arn != ""
}

output "github_actions_deploy_role_arn" {
  value = var.create_github_actions_oidc_resources ? aws_iam_role.github_actions_deploy[0].arn : null
}

output "github_actions_oidc_provider_arn" {
  value = var.create_github_actions_oidc_resources ? aws_iam_openid_connect_provider.github_actions[0].arn : null
}
