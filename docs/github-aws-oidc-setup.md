# GitHub OIDC AWS Setup

This guide prepares the repository deployment workflow to build an image, push it to Amazon ECR, and deploy it to Amazon EKS without storing long-lived AWS keys in GitHub.

## Recommended assignment setup

For a short-lived assessment, the fastest safe path is:

1. Create a GitHub OIDC provider in AWS IAM.
2. Create one IAM role for GitHub Actions deployment.
3. Trust only this repository on the `develop` branch.
4. Temporarily attach broad permissions to that role for the assessment run.
5. Pass the role ARN into Terraform so EKS grants the role cluster access.
6. Store the role ARN in GitHub as `AWS_DEPLOY_ROLE_ARN`.

After the assessment, reduce permissions or delete the role.

## 1. Create the OIDC provider

In AWS IAM, create an OpenID Connect provider with:

- Provider URL: `https://token.actions.githubusercontent.com`
- Audience: `sts.amazonaws.com`

## 2. Create the deploy role trust policy

Use this trust policy for the current repository and branch:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::063884340510:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:ashishkarpe/DevSecOps-Assignment-maltem:ref:refs/heads/develop"
        }
      }
    }
  ]
}
```

Note:

- This repository was created before July 15, 2026, so the classic `sub` format above is the expected starting point unless immutable subject claims were explicitly enabled.
- If you later deploy from environments instead of directly from the branch, the `sub` claim format changes.

## 3. Attach permissions to the deploy role

For this assessment, the fastest route is to temporarily attach:

- `AdministratorAccess`

That is broader than production best practice, but it avoids spending more time than the assignment merits on fine-grained IAM debugging.

If you want a more restricted follow-up later, split responsibilities between:

- ECR push permissions
- EKS describe and cluster access
- Optional read-only permissions for rollout verification

## 4. Add the role ARN to GitHub

In the GitHub repository settings, add this secret:

- `AWS_DEPLOY_ROLE_ARN`

Value example:

```text
arn:aws:iam::063884340510:role/github-actions-redemption-deploy
```

## 5. Grant the role EKS access through Terraform

Pass the same role ARN during Terraform plan and apply:

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

This repository's Terraform now creates:

- An ECR repository for the app image
- An EKS access entry for the GitHub deploy role
- An EKS admin policy association for that deploy role
- The AWS Load Balancer Controller with IRSA when enabled

## 6. Trigger deployment from GitHub

After Terraform finishes successfully:

1. Open the `Build And Deploy To EKS` workflow.
2. Run it manually.
3. Set `deploy_to_eks` to `true`.
4. Leave `image_tag` empty to use the commit SHA, or provide your own tag.

## 7. Expected cost impact

OIDC provider, IAM role, and EKS access entry themselves do not materially add runtime cost.

Cost begins when you create infrastructure such as:

- EKS control plane
- EC2 worker nodes
- NAT gateway
- ALB
- CloudWatch log storage

## 8. Cleanup

After the assignment:

1. Destroy the Terraform-managed infrastructure.
2. Delete or detach broad permissions from the GitHub deploy role.
3. Remove the GitHub secret if no longer needed.

