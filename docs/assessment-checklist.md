# Assessment Checklist

Source: Cloud Engineer Assessment 2026.pdf, kept local and excluded from git.

Legend:

- `[x]` done
- `[~]` partial
- `[ ]` not done

## Assessment Requirements

- [x] Identify the scenario and business constraint from the brief
- [x] Define the application as a containerized workload on AWS EKS
- [x] Describe how the service stays available during extreme load and infrastructure failures
- [x] Define a scaling strategy that handles 10x traffic spikes without manual intervention
- [x] Design network and security controls using least privilege and defense in depth
- [x] Define health, recovery, and observability mechanisms
- [x] Provide a 3-person task split with 1 senior and 2 juniors
- [x] Add optional AI/ML production-readiness guidance for prompt, skill, and guardrail controls

## Deliverables

- [~] GitHub repository with functional Terraform
- [x] Kubernetes manifests for the workload
- [x] Architecture diagram as draw.io/exported image with production boundaries
- [x] Design document exported as PDF

## DevSecOps Pipeline

- [x] GitHub Actions workflow added
- [x] Gitleaks stage added
- [x] Trivy filesystem and IaC scan stage added
- [x] Trivy SBOM generation stage added
- [x] SonarQube stage added
- [x] OWASP ZAP baseline stage added

## What is already in the repo

- [x] `terraform/` folder created
- [x] `terraform/.terraform.lock.hcl` created by `terraform init`
- [x] `k8s/` folder created
- [x] `docs/design.md` created
- [x] `docs/ai-ml-production-readiness.md` created
- [x] `docs/aws-test-runbook.md` created
- [x] `docs/design.pdf` created
- [x] `docs/architecture.drawio` created
- [x] `docs/architecture.svg` created
- [x] `README.md` created
- [x] `sonar-project.properties` created

## Local Verification

- [x] Terraform formatting passes with `terraform -chdir=terraform fmt -check`
- [x] Terraform initialized with `terraform -chdir=terraform init -backend=false`
- [~] Terraform validation attempted, but local AWS provider schema startup timed out on this machine
- [x] Kubernetes YAML parses successfully
- [~] Kubernetes client dry-run attempted, but the configured local cluster endpoint is not running
- [x] GitHub Actions workflow YAML parses successfully
- [x] Architecture XML/SVG parses successfully with `xmllint`
- [x] Architecture diagram includes public/private subnets, NAT gateways, ALB controller, ECR flow, CI/CD, IAM/IRSA, and monitoring paths
- [x] `docs/design.pdf` exists and is recognized as a 2-page PDF
- [x] AWS budget guardrail added as optional Terraform resource

## Remaining gaps before calling it fully done

- [ ] Run `terraform validate`, `plan`, and `apply` in an environment where the AWS provider starts cleanly and AWS credentials are configured
- [ ] If you want a fully production-realistic workload, replace the demo container with the actual application image and wire its build step
