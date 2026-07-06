# Cloud Engineer Assessment 2026

This workspace contains a submission scaffold for the Accor Thailand cloud engineer assessment.

## Contents

- `terraform/` - AWS EKS infrastructure as code
- `k8s/` - Kubernetes manifests for the service
- `docs/design.md` - Architecture and execution summary
- `docs/design.pdf` - Exported design document for submission
- `docs/ai-ml-production-readiness.md` - Optional AI/ML guardrails and production readiness guidance
- `docs/aws-test-runbook.md` - Safe AWS plan/apply/destroy test procedure with budget guardrails
- `docs/terraform-troubleshooting.md` - Terraform validation notes for Apple Silicon/tfenv
- `docs/architecture.drawio` - Draw.io source for the architecture diagram
- `docs/architecture.svg` - Exported architecture diagram image
- `.github/workflows/devsecops.yml` - CI/CD pipeline with Gitleaks, Trivy, SBOM generation, SonarQube, and OWASP ZAP
- `.github/workflows/deploy.yml` - Manual build and deploy workflow for ECR and EKS
- `Dockerfile` - Container image for the demo Redemption service
- `app/` - Minimal static application content served by nginx

## What this solution is designed to show

- A containerized application platform on AWS EKS
- Automatic scaling for flash-sale traffic spikes
- Security boundaries using least privilege and defense in depth
- Multi-AZ resilience and operational simplicity
- Optional AI/ML guardrails for future production features
- A clear team execution split for 3 engineers

## Suggested next step

Review `docs/design.md` first. `docs/design.pdf` is the exported submission document, `docs/architecture.drawio` holds the diagram source, and `docs/architecture.svg` is the exported diagram image.

## DevSecOps pipeline

The GitHub Actions workflow expects these secrets when you want SonarQube analysis to run:

- `SONAR_TOKEN`
- `SONAR_HOST_URL`
- `SONAR_PROJECT_KEY`

If those secrets are missing, the SonarQube job skips cleanly while the other scans still run.

The pipeline also generates a CycloneDX SBOM with Trivy and uploads it as a workflow artifact.

## Delivery pipeline

The repository also contains a manual deployment workflow that builds the application image, pushes it to Amazon ECR, and deploys it to Amazon EKS.

It expects these prerequisites:

- Terraform has already created the EKS cluster and ECR repository
- GitHub secret `AWS_DEPLOY_ROLE_ARN` exists for OIDC-based AWS authentication
- The cluster has the prerequisites needed by the manifests, especially the AWS Load Balancer Controller for the `Ingress`

The deployment workflow is intentionally `workflow_dispatch` only so it does not create cost or change AWS resources on every push.
