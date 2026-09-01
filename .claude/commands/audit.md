---
description: Run the agent-based audit system (security, accessibility, performance, compatibility, Rails practices, data integrity, dependencies, test quality).
argument-hint: [topics] [--report]
---

Determine the requested topics from $ARGUMENTS: a space- or comma-separated list of topics (e.g. `security accessibility`) or `--report` to also write an aggregate report file. If $ARGUMENTS is empty or `all`, audit every topic.

Delegate to the `audit-orchestrator` subagent, passing the exact topic list, and pass through the `--report` flag so it writes the report to `docs/audits/YYYY-MM-DD.md`.
