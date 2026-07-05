variable "region" {
  type    = string
  default = "ap-southeast-1"
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
  type    = string
  default = "redemption-eks"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

variable "budget_limit_usd" {
  type        = number
  default     = 20
  description = "Monthly AWS Budget guardrail in USD for the assessment test."
}

variable "budget_notification_email" {
  type        = string
  default     = ""
  description = "Email address for AWS Budget notifications. Leave empty to skip budget creation."
}
