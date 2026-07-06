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
