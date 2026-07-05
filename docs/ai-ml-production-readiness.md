# AI/ML Production Readiness

This section is optional for the current assessment because the brief is primarily about an AWS EKS microservice. If the Redemption service later introduces AI features, such as automated support, fraud triage, points-deduction explanations, or incident copilots, the following controls should be added before production use.

## AI Use Cases

- Customer-support summarization for failed or disputed point deductions.
- SRE incident assistant that summarizes logs, alerts, and runbooks.
- Fraud or anomaly triage for unusual redemption patterns.
- Internal knowledge assistant for operational procedures.

## Prompt and Skill Governance

- Store prompts, tools, and agent skills in version control.
- Review prompt changes through pull requests.
- Treat prompts as production configuration with owners, rollback history, and release notes.
- Separate system instructions, user input, retrieved context, and tool outputs.
- Use environment-specific prompts for dev, staging, and production.

## Guardrails

- Validate and sanitize user input before sending it to an AI model.
- Block prompt-injection attempts that try to override system or developer instructions.
- Redact or tokenize PII before model calls where possible.
- Restrict model tools using least privilege and allowlists.
- Require human approval before high-impact actions, such as account changes, refunds, or points adjustment.
- Log model decisions, tool calls, and safety outcomes for auditability.

## Evaluation and Release Controls

- Maintain an evaluation dataset with expected outputs and refusal cases.
- Run regression tests before changing prompts, model versions, retrieval sources, or tools.
- Track accuracy, hallucination rate, policy violations, latency, and cost.
- Use canary deployments for AI workflow changes.
- Keep a rollback plan for model or prompt regressions.

## Observability

- Capture model latency, token usage, error rate, refusal rate, and fallback rate.
- Monitor guardrail blocks and suspicious prompt-injection attempts.
- Correlate AI events with application traces and incident timelines.
- Alert on unusual cost spikes or behavior drift.

## Data Protection

- Minimize data sent to external model providers.
- Encrypt logs and request traces.
- Apply retention limits to model interaction logs.
- Use private networking and IAM-scoped access for model gateways where supported.

## Production Recommendation

Do not let AI directly mutate customer points or financial records without deterministic validation and human approval. AI can assist analysis and decision support, but the final transaction path should remain auditable, deterministic, and protected by existing business rules.

