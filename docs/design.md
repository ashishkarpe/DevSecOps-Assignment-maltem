# Cloud Engineer Assessment 2026

## Executive Summary

This solution places the Redemption microservice on Amazon EKS behind an Application Load Balancer and designs the platform to survive flash-sale traffic spikes, AZ-level failures, and bad deployments with minimal customer impact. The workload runs in private subnets, scales automatically at the pod and node layers, and uses Terraform plus Kubernetes manifests as the core delivery model.

## Architecture Overview

- Amazon EKS hosts the application in containers.
- An internet-facing ALB routes traffic into Kubernetes.
- Worker nodes run in private subnets across multiple Availability Zones.
- Horizontal Pod Autoscaler scales the service based on demand.
- Cluster Autoscaler or Karpenter adds nodes when the cluster runs out of capacity.
- CloudWatch captures logs and metrics for operational visibility.

The architecture diagram is available as `docs/architecture.svg`, with editable source in `docs/architecture.drawio`. It shows the production boundaries for CI/CD, ECR image flow, public and private subnets, NAT gateways, the ALB path, EKS workloads, cluster controllers, IAM/IRSA, Secrets Manager, and CloudWatch alerting.

## Scaling Strategy

- Set pod requests and limits so the scheduler can place workloads predictably.
- Use HPA to scale on CPU and memory utilization.
- Use node autoscaling so new pods can be scheduled during bursts.
- Spread replicas across AZs to keep capacity available during an outage.
- Start scaling early rather than waiting for saturation, because the business case is a short-lived but intense traffic spike.

## Reliability Strategy

- Run the service across at least two AZs, ideally three.
- Use health checks so unhealthy pods are replaced quickly.
- Use rolling updates with `maxUnavailable: 0` to avoid avoidable downtime.
- Add a Pod Disruption Budget so routine maintenance does not reduce capacity too aggressively.
- Keep application state outside the container image so failed pods can be replaced safely.

## Security and Networking

- Keep worker nodes in private subnets.
- Expose only the ALB to the internet.
- Use IAM roles for service accounts instead of broad node permissions.
- Store secrets in AWS Secrets Manager or SSM Parameter Store.
- Apply least privilege to security groups, ingress rules, and workload access.
- Add network policy controls to reduce unnecessary egress from pods.

## Observability and Day 2 Operations

- Use CloudWatch for logs and platform metrics.
- Use readiness, liveness, and startup probes to improve recovery behavior.
- Track latency, error rate, and saturation for alerting.
- Manage infrastructure with Terraform so changes are repeatable and reviewable.
- Keep deployment and rollback runbooks simple to reduce operational toil.

## AI/ML Production Readiness

AI/ML is not required by the assessment brief, but the platform can support AI-assisted operations or customer-support workflows in a production-safe way. Any AI capability should use version-controlled prompts and skills, prompt-injection defenses, PII redaction, tool allowlists, human approval for high-impact actions, and regression evaluations before release. AI should assist investigation and decision support, while points deduction and customer-impacting transactions remain deterministic and auditable.

The detailed AI/ML guardrail plan is available in `docs/ai-ml-production-readiness.md`.

## Team Delegation Plan

### Senior Engineer

- Own architecture and technical decisions.
- Review Terraform structure, resilience, and security.
- Approve rollout strategy and final integration.

### Junior Engineer 1

- Build VPC, EKS, IAM, and cluster infrastructure in Terraform.
- Support ALB controller prerequisites and networking setup.

### Junior Engineer 2

- Build Kubernetes manifests for deployment, service, ingress, autoscaling, and disruption control.
- Add operational details such as probes, resource limits, and network policy.

## Trade-offs

- EKS provides flexibility and strong alignment with the assignment, but it is more complex than a managed PaaS.
- Karpenter is efficient for bursty capacity, while Cluster Autoscaler is simpler to explain and operate.
- Network policies improve segmentation, but they require careful tuning to avoid blocking valid traffic.

## Submission Notes

This document is written in a PDF-ready format and can be exported directly for the assignment submission pack.
