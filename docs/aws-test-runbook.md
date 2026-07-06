# AWS Test Runbook

This runbook is for validating the assessment in AWS account `063884340510` using profile `avaniakarpe` and region `ap-southeast-1`.

## Budget Guardrail

Recommended assessment test budget:

- Soft alert: `$20 / ~INR 1,660 / ~THB 720`
- Hard internal stop: `$50 / ~INR 4,150 / ~THB 1,800`
- Available AWS credits reported by account owner: `$100 / ~INR 8,300 / ~THB 3,600`

The Terraform budget resource is optional. It is created only when `budget_notification_email` is set.

## 1. Configure AWS Profile

```bash
aws configure --profile avaniakarpe
```

Verify identity before running Terraform:

```bash
aws sts get-caller-identity --profile avaniakarpe
```

Expected account:

```text
063884340510
```

## 2. Plan First

If using `tfenv` on Apple Silicon, check `docs/terraform-troubleshooting.md` before running Terraform.

If you want GitHub Actions to deploy to EKS later, set up the OIDC role first using `docs/github-aws-oidc-setup.md`.

```bash
terraform -chdir=terraform init
terraform -chdir=terraform validate
terraform -chdir=terraform plan \
  -var aws_profile=avaniakarpe \
  -var region=ap-southeast-1
```

To include the budget guardrail in the plan, provide an email address:

```bash
terraform -chdir=terraform plan \
  -var aws_profile=avaniakarpe \
  -var region=ap-southeast-1 \
  -var budget_notification_email=your-email@example.com
```

To include GitHub deployment access in the cluster plan:

```bash
terraform -chdir=terraform plan \
  -var aws_profile=avaniakarpe \
  -var region=ap-southeast-1 \
  -var github_deploy_role_arn=arn:aws:iam::063884340510:role/github-actions-redemption-deploy
```

## 3. Apply Only After Reviewing The Plan

Estimated cost for a short live test:

- 2-4 hours: `$2-$7 / ~INR 166-581 / ~THB 72-252`
- Same-day safety cap: `$25-$50 / ~INR 2,075-4,150 / ~THB 900-1,800`

```bash
terraform -chdir=terraform apply \
  -var aws_profile=avaniakarpe \
  -var region=ap-southeast-1
```

## 4. Deploy Kubernetes Manifests

After the EKS cluster is created:

```bash
aws eks update-kubeconfig \
  --name redemption-eks \
  --region ap-southeast-1 \
  --profile avaniakarpe

kubectl apply -f k8s/
kubectl get pods -n redemption
kubectl get ingress -n redemption
```

Or use the manual GitHub Actions deployment workflow after these prerequisites are in place:

- The ECR repository from Terraform exists
- The GitHub repository has secret `AWS_DEPLOY_ROLE_ARN`
- The EKS cluster can trust GitHub OIDC through that role
- The cluster has the AWS Load Balancer Controller installed if you want the `Ingress` to become an ALB

The workflow builds the image from `Dockerfile`, pushes it to ECR, applies the manifests, then updates the deployment image and waits for rollout.

## 5. Destroy Same Day

Destroy the Kubernetes workload first:

```bash
kubectl delete -f k8s/ --ignore-not-found=true
```

Then destroy AWS infrastructure:

```bash
terraform -chdir=terraform destroy \
  -var aws_profile=avaniakarpe \
  -var region=ap-southeast-1
```

## Post-Destroy Cleanup Checks

Run these checks and confirm no assessment resources remain:

```bash
aws eks list-clusters --region ap-southeast-1 --profile avaniakarpe
aws elbv2 describe-load-balancers --region ap-southeast-1 --profile avaniakarpe
aws ec2 describe-nat-gateways --region ap-southeast-1 --profile avaniakarpe
aws ec2 describe-addresses --region ap-southeast-1 --profile avaniakarpe
aws ec2 describe-volumes --region ap-southeast-1 --profile avaniakarpe
```

Also check the AWS Console for:

- EKS clusters
- EC2 instances
- NAT gateways
- Load balancers
- Elastic IP addresses
- EBS volumes
- CloudWatch log groups
