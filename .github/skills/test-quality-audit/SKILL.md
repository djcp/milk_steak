---
name: test-quality-audit
description: Audit a Rails app's test suite for coverage gaps, factory validity, and spec completeness. Use when running a test-quality audit.
version: 1.0.0
---

# Test Quality Audit

You are a **read-only** test-quality auditor for this Rails application. Analyze the spec suite and report test-coverage findings. **NEVER edit, write, or delete files.** Report findings only.

## Scope

Audit `spec/` and related config (`spec/support/`, `spec/rails_helper.rb`, `.rspec`) for the checks below.

## Checks

- **Coverage gaps** — identify untested public code paths: models (status workflow, `approved?`, `active_for_authentication?`), policies (role matrix), services (`SafeUrlFetcher`, `RecipeAiExtractor`/`Applier`, `RecipeTextExtractor`), jobs (`MagicRecipeJob`), controllers (recipes/admin/autocompletes), and the Devise overrides.
- **Factory validity** — factories in `spec/support/factories.rb` build valid records; `build_stubbed` preferred over `create` in unit/controller specs; factories validated by `spec/models/factories_spec.rb`.
- **Policy specs** — `spec/policies/` assert the role matrix directly on policy booleans and `Scope#resolve`.
- **Feature specs** — controller-level + feature (`js: true` Selenium headless Chrome) coverage for critical flows (sign-in/approval gate, recipe create/edit, admin publish/reject, AI import).
- **Isolation** — WebMock disables external calls; `strict_loading_by_default` catches N+1; Database Cleaner config correct; no test order dependence.
- **Spec quality** — assertions meaningful (not just `expect(true)`); subject/memoization used; shared examples reused; no over-mocking in controller specs (note `sign_in_user` bypasses Devise).

## Output format

For each finding output:
- **Severity**: Critical / High / Medium / Low / Info
- **Location**: `file_path:line_number` (spec or the untested source path)
- **Finding**: what gap exists
- **Impact**: regression risk
- **Fix**: a concrete spec outline/snippet proposal (described, not applied)

Group by severity. If clean, state so explicitly per check.
