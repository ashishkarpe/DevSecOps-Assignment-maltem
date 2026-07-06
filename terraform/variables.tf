variable "region" {
  type        = string
  default     = "ap-southeast-1"
  description = "AWS region for the assessment deployment."
}

variable "aws_profile" {
  type        = string
  default     = ""
  description = "Optional local AWS CLI profile name, for example avaniakarpe."
}

variable "expected_account_id" {
  type        = string
  default     = "063884340510"
  description = "AWS account expected for validation and deployment."
}

variable "cluster_name" {
  type        = string
  default     = "redemption-eks"
  description = "EKS cluster name."
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the assessment VPC."
}

variable "azs" {
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  description = "Availability Zones used for public/private subnet placement."

  validation {
    condition     = length(var.azs) == 3
    error_message = "Exactly three Availability Zones are required because the subnet CIDRs are defined for three AZs."
  }
}

variable "budget_limit_usd" {
  type        = number
  default     = 20
  description = "Monthly AWS Budget guardrail in USD for the assessment test."

  validation {
    condition     = var.budget_limit_usd > 0
    error_message = "budget_limit_usd must be greater than zero."
  }
}

variable "budget_notification_email" {
  type        = string
  default     = ""
  description = "Email address for AWS Budget notifications. Leave empty to skip budget creation."
}

variable "ecr_repository_name" {
  type        = string
  default     = "redemption"
  description = "Amazon ECR repository name used by the application deployment pipeline."
}

variable "enable_alb_controller" {
  type        = bool
  default     = true
  description = "Install the AWS Load Balancer Controller with IRSA when true."
}

variable "github_deploy_role_arn" {
  type        = string
  default     = ""
  description = "Optional GitHub Actions OIDC deploy role ARN that should receive EKS cluster access."
}

variable "create_github_actions_oidc_resources" {
  type        = bool
  default     = true
  description = "Create the GitHub Actions OIDC provider and deploy role in AWS when true."
}

variable "github_actions_deploy_role_name" {
  type        = string
  default     = "github-actions-redemption-deploy"
  description = "IAM role name assumed by the GitHub Actions deployment workflow."
}

variable "github_repository_subject" {
  type        = string
  default     = "repo:ashishkarpe/DevSecOps-Assignment-maltem:ref:refs/heads/develop"
  description = "GitHub OIDC subject claim allowed to assume the deployment role."
}

variable "github_oidc_thumbprint" {
  type        = string
  default     = "6938fd4d98bab03faadb97b34396831e3780aea1"
  description = "Thumbprint used for the GitHub Actions OIDC provider."
}

variable "attach_admin_policy_to_github_deploy_role" {
  type        = bool
  default     = true
  description = "Attach AdministratorAccess to the GitHub deploy role for the short assessment run."
}
