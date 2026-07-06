# GitHub OIDC AWS Setup

This guide prepares the repository deployment workflow to build an image, push it to Amazon ECR, and deploy it to Amazon EKS without storing long-lived AWS keys in GitHub.

The repository can now create the OIDC provider and deployment role directly with Terraform.

## Recommended assignment setup

For a short-lived assessment, the fastest safe path is:

1. Let Terraform create the GitHub OIDC provider in AWS IAM.
2. Let Terraform create one IAM role for GitHub Actions deployment.
3. Trust only this repository on the `develop` branch.
4. Temporarily attach broad permissions to that role for the assessment run.
5. Let Terraform grant that role EKS cluster access.
6. Store the role ARN output in GitHub as `AWS_DEPLOY_ROLE_ARN`.

After the assessment, reduce permissions or delete the role.

## 1. Terraform-managed OIDC resources

By default, Terraform now creates:

- The GitHub OIDC provider
- The GitHub deploy role
- An `AdministratorAccess` attachment for the short assessment run
- An EKS access entry and EKS admin policy association for that role

The default trusted GitHub subject is:

```text
repo:ashishkarpe/DevSecOps-Assignment-maltem:ref:refs/heads/develop
```

Note:

- This repository was created before July 15, 2026, so the classic `sub` format above is the expected starting point unless immutable subject claims were explicitly enabled.
- If you later deploy from environments instead of directly from the branch, the `sub` claim format changes.

## 2. Apply Terraform and capture the role ARN

Run:

```bash
terraform -chdir=terraform plan \
  -var aws_profile=avaniakarpe \
  -var region=ap-southeast-1
```

```bash
terraform -chdir=terraform apply \
  -var aws_profile=avaniakarpe \
  -var region=ap-southeast-1
```

Then read the role ARN from:

```bash
terraform -chdir=terraform output github_actions_deploy_role_arn
```

If you want to override the defaults, the main variables are:

- `create_github_actions_oidc_resources`
- `github_actions_deploy_role_name`
- `github_repository_subject`
- `attach_admin_policy_to_github_deploy_role`

## 3. Add the role ARN to GitHub

In the GitHub repository settings, add this secret:

- `AWS_DEPLOY_ROLE_ARN`

Value example:

```text
arn:aws:iam::063884340510:role/github-actions-redemption-deploy
```

## 4. Optional override for an externally created role

If you prefer to create the role outside Terraform, pass it in explicitly:

```bash
terraform -chdir=terraform plan \
  -var aws_profile=avaniakarpe \
  -var region=ap-southeast-1 \
  -var github_deploy_role_arn=arn:aws:iam::063884340510:role/github-actions-redemption-deploy
```

```bash
terraform -chdir=terraform apply \
  -var aws_profile=avaniakarpe \
  -var region=ap-southeast-1 \
  -var github_deploy_role_arn=arn:aws:iam::063884340510:role/github-actions-redemption-deploy
```

## 5. Trigger deployment from GitHub

After Terraform finishes successfully:

1. Open the `Build And Deploy To EKS` workflow.
2. Run it manually.
3. Set `deploy_to_eks` to `true`.
4. Leave `image_tag` empty to use the commit SHA, or provide your own tag.

## 6. Expected cost impact

OIDC provider, IAM role, and EKS access entry themselves do not materially add runtime cost.

Cost begins when you create infrastructure such as:

- EKS control plane
- EC2 worker nodes
- NAT gateway
- ALB
- CloudWatch log storage

## 7. Cleanup

After the assignment:

1. Destroy the Terraform-managed infrastructure.
2. Delete or detach broad permissions from the GitHub deploy role.
3. Remove the GitHub secret if no longer needed.
