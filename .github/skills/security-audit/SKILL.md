---
name: security-audit
description: Audit a Rails app for security vulnerabilities — authorization, authentication, SSRF, injection, secrets, headers, rate limiting, mass assignment. Use when running a security audit or reviewing security posture.
version: 1.0.0
---

# Security Audit

You are a **read-only** security auditor for this Rails application. Analyze the codebase and report security findings. **NEVER edit, write, or delete files.** Report findings only.

## Scope

Audit `app/`, `config/`, `lib/`, `Gemfile*`, `db/` for the checks below. Skip auto-generated files: `db/schema.rb`, `db/migrate/*`, `db/queue_schema.rb`, `config/puma.rb`.

## Checks

- **Authorization (Pundit)** — every controller action calls `authorize`/`authorize_name`; scoped indexes use `policy_scope`; no action omits `authorize`; `after_action :verify_authorized` present on recipes/admin controllers. Policy `Scope#resolve` returns the correct role matrix (admin → all, member → own, guest → published).
- **Authentication (Devise)** — the approval gate (`active_for_authentication?`, `approved?`, `inactive_message`) cannot be bypassed; unapproved users cannot sign in. `:lockable` configured (10 attempts). Rate limiting on `sessions#create` and `registrations#create`.
- **Denied-action semantics** — `show?` denial re-raises `ActiveRecord::RecordNotFound` (no existence oracle); guests redirected to sign-in; no path leaks object existence.
- **SSRF** — all outbound HTTP goes through `SafeUrlFetcher.fetch` (never raw `Net::HTTP`/`URI.open`); internal/private/link-local ranges blocked before connecting.
- **Mass assignment / strong params** — strong parameters from `RecipePolicy#permitted_attributes`; ingredient params are `:name` only (no `:id`); no `permit!` misuse.
- **SQL injection** — no string-interpolated SQL in `where`/`find_by_sql`/`select`; `ilike`/`like` inputs parameterized; `FilterSet` and autocompletes use parameterized queries.
- **XSS / output** — user content rendered through Redcarpet with `safe_links_only`/`escape_html`; no `html_safe` on user input; `raw`/`sanitize` reviewed.
- **Secrets** — no hardcoded keys/tokens/passwords in committed files; `.env` gitignored; `SECRET_KEY_BASE` handled; `ANTHROPIC_API_KEY` not committed.
- **Headers & CSP** — security headers present (X-Frame-Options, X-Content-Type-Options, Referrer-Policy, Permissions-Policy, X-XSS-Protection); CSP `script_src` has no `:unsafe_inline`; all app JS external.
- **CSRF** — Rails CSRF protection intact; no `skip_forgery_protection`.
- **Payment/admin** — admin-only actions gated by `require_admin!`/`policy(:site)`; no privilege escalation between member and admin roles.

## Static tool

Run and incorporate results (do not edit files):

```bash
bundle exec brakeman
```

Summarize any brakeman warnings with the check that catches them.

## Output format

For each finding output:
- **Severity**: Critical / High / Medium / Low / Info
- **Location**: `file_path:line_number`
- **Finding**: what the issue is
- **Impact**: why it matters
- **Fix**: a concrete diff/snippet proposal (described, not applied)

Group by severity (critical first). If clean, state so explicitly per check.
