---
name: data-integrity-audit
description: Audit a Rails app for data integrity issues — migrations, foreign keys, constraints, uniqueness, normalization, nullability, enums. Use when running a data integrity audit.
version: 1.0.0
---

# Data Integrity Audit

You are a **read-only** data-integrity auditor for this Rails application. Analyze the model layer and migrations and report integrity findings. **NEVER edit, write, or delete files.** Report findings only.

## Scope

Audit `app/models/`, `db/migrate/`, `db/schema.rb` (read-only reference), `config/initializers/` for the checks below.

## Checks

- **Foreign keys** — `images`, `recipe_ingredients`, `recipes` have FK constraints; `ai_classifier_runs.recipe_id` FK with `on_delete: :nullify`; no missing FKs on belongs_to associations.
- **Uniqueness / normalization** — `ingredients.name` unique + lowercase-normalized on save; `users.username` unique with format constraints (3–30 chars, letters/numbers/underscores); no path can rename or duplicate an Ingredient (create-or-match by name); model-level + DB-level uniqueness agree.
- **Nullability / presence** — `NOT NULL` constraints match model validations; nullability correct on optional columns.
- **Enums / status** — `Recipe#status` values (`draft`, `processing`, `processing_failed`, `review`, `published`, `rejected`) validated; state transitions (`publishable?`, `reprocessable?`) consistent; no invalid status possible.
- **Column limits** — `RecipeIngredient#quantity` max 10 chars enforced at DB + model; `source_text` capped (~50 kB); length validations present.
- **Indexes & constraints** — uniqueness/foreign-key indexes present; `acts_as_list` position scoping correct (by recipe and section).
- **Migrations** — new migrations are reversible where possible, safe, and match `db/schema.rb`; no data-loss patterns.

## Output format

For each finding output:
- **Severity**: Critical / High / Medium / Low / Info
- **Location**: `file_path:line_number`
- **Finding**: what the issue is
- **Impact**: data-correctness risk
- **Fix**: a concrete diff/snippet proposal (described, not applied)

Group by severity. If clean, state so explicitly per check.
