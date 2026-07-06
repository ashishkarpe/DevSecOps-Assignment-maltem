# Cloud Engineer Assessment 2026

Source: `Cloud Engineer Assessment 2026.pdf`

## Overview

Position: Cloud Engineer

Company: Accor

Scenario:

The Redemption is a business-critical microservice on AWS EKS that handles global hotel point deductions. It has a steady baseline load with sudden 10x flash-sale spikes and a zero-downtime target because outages directly affect revenue.

## Assessment Requirements

### A. Compute & Architecture

Design a containerized infrastructure on AWS EKS.

Show how the application stays available and responsive during extreme load and infrastructure failures.

### B. Scalability Strategy

Automatically handle the 10x traffic spike without manual intervention.

Define scaling for both the application and the underlying infrastructure.

### C. Security & Networking

Design a network and security architecture that protects customer data and infrastructure integrity.

Apply Least Privilege and Defense in Depth across the stack.

### D. Reliability & Observability

Define how service health will be measured.

Define how the system recovers from failures such as AZ outage or bad deployment with minimal customer impact.

### E. Operations

Propose Day 2 operations strategies to minimize toil.

Outline task assignment across a team of 3 engineers:

- 1 Senior
- 2 Juniors

## Deliverables

1. GitHub repository with functional Infrastructure as Code, Terraform preferred, and Kubernetes manifests.
2. Architecture diagram as a high-level draw.io or exported image showing data flow and AWS components.
3. Design document in PDF with an executive summary of architecture decisions, trade-offs, and team delegation plan.

## Submission Note

The brief requests a response that is well-structured and concise.

The deadline is 7 days from the date of receipt.

## Working Rule For This Repo

Do not launch any AWS resource without explicit user approval first.

