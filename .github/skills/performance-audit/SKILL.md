---
name: performance-audit
description: Audit a Rails app for performance issues — N+1 queries, missing indexes, eager loading, image variants, pagination, background jobs. Use when running a performance audit.
version: 1.0.0
---

# Performance Audit

You are a **read-only** performance auditor for this Rails application. Analyze the codebase and report performance findings. **NEVER edit, write, or delete files.** Report findings only.

## Scope

Audit `app/controllers/`, `app/models/`, `app/services/`, `app/jobs/`, `db/`, `config/` for the checks below.

## Checks

- **N+1 queries** — controllers/indexes eager-load associations with `Recipe.includes(...)`; image blobs eager-loaded via `includes(images: { image_attachment: :blob })`; no lazy association loads in loops/views; `strict_loading_by_default` respected in test.
- **Indexes** — trigram GIN indexes present on `recipes(lower(name))`, `ingredients(lower(name))`, `users(username)`; composite indexes on `recipes(user_id, status)` and `recipes(status, created_at)`; unique index on `ingredients(name)`; new query patterns have supporting indexes; no obviously missing indexes for frequent `where`/`order`.
- **Query efficiency** — `ilike`/`like` substring searches use trigram indexes (`pg_trgm` enabled); `GROUP BY` aggregate queries bounded; avoidance of `N+1` via `joins`/`includes` where appropriate.
- **Pagination** — `will_paginate` with `page` clamped (≥ 1) and `per_page` (1–48); no unbounded `all`/`limit` misuse.
- **Image variants** — Active Storage `:tiny` (32×32), `:thumb` (187×187), `:large` (800×600) used appropriately; no processing of full-resolution images where a variant suffices.
- **Background jobs** — AI pipeline work offloaded to Solid Queue (`MagicRecipeJob`); no heavy work in the request cycle; job queue configured correctly.
- **N+1 in JSON endpoints** — autocomplete controllers query efficiently (`published` scoped, fuzzy autocomplete via trigram).
- **Caching / deflation** — `Rack::Deflater` enabled; any candidate caching opportunities noted but not blocking.

## Output format

For each finding output:
- **Severity**: Critical / High / Medium / Low / Info
- **Location**: `file_path:line_number`
- **Finding**: what the issue is
- **Impact**: estimated cost (queries, memory, latency)
- **Fix**: a concrete diff/snippet proposal (described, not applied)

Group by severity. If clean, state so explicitly per check.
