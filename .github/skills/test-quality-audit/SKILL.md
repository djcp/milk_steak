---
name: test-quality-audit
description: Audit a Rails app's test suite for coverage gaps, factory validity, spec completeness, flakiness, suite efficiency, and low-value tests. Use when running a test-quality audit.
version: 1.1.0
---

# Test Quality Audit

You are a **read-only** test-quality auditor for this Rails application. Analyze the spec suite and report test-coverage findings. **NEVER edit, write, or delete files.** Report findings only.

## Scope

Audit `spec/` and related config (`spec/support/`, `spec/spec_helper.rb`, `.rspec`, and any test-only assets such as `app/assets/javascripts/test_setup.js` and the partial that includes it) for the checks below.

## Checks

- **Coverage gaps** — identify untested public code paths: models (status workflow, `approved?`, `active_for_authentication?`), policies (role matrix), services (`SafeUrlFetcher`, `RecipeAiExtractor`/`Applier`, `RecipeTextExtractor`), jobs (`MagicRecipeJob`), controllers (recipes/admin/autocompletes), and the Devise overrides.
- **Factory validity** — factories in `spec/support/factories.rb` build valid records; `build_stubbed` preferred over `create` in unit/controller specs; factories validated by `spec/models/factories_spec.rb`.
- **Policy specs** — `spec/policies/` assert the role matrix directly on policy booleans and `Scope#resolve`.
- **Feature specs** — end-to-end coverage for critical flows (sign-in/approval gate, recipe create/edit, admin publish/reject, AI import), at the cheapest driver that exercises the behaviour: `rack_test` by default, `js: true` (Selenium headless Chrome) only where JavaScript is the subject.
- **Isolation** — WebMock disables external calls; `strict_loading_by_default` catches N+1; Database Cleaner config correct; no test order dependence.
- **Spec quality** — assertions meaningful (not just `expect(true)`); subject/memoization used; shared examples reused; no over-mocking in controller specs (note `sign_in_user` bypasses Devise).
- **Determinism** — a suite that fails intermittently is a defect, not weather. Look for: a click or form submit whose navigation is never awaited before the next DOM query (the next query then races the navigation, and chromedriver reports the detached node as an `UnknownError` Capybara does not retry); helpers that poll a signal the page does not emit yet (polling `jQuery.active` right after a `fill_in` misses jQuery UI's `options.delay` window entirely and waits for nothing); `after`-hook ordering between `DatabaseCleaner.clean` and Capybara's `reset_sessions!` (RSpec runs plain `after` hooks in *reverse* registration order, so a later-registered `clean` truncates while the browser session is still open — it belongs in `append_after`); test-only JavaScript that never executes because of script ordering or a missing `defer`, silently disabling the determinism it was added to provide; index- or count-based element selection (`all(...)[2]`, `all(...).count`) that samples the DOM once instead of waiting; bare `sleep`; and driver errors that fall outside `Capybara::Selenium::Driver#invalid_element_errors`. Assert the harness's own invariants in a spec — a silent no-op is exactly what a suite should catch about itself.
- **Suite efficiency** — `js: true` on specs where nothing under test is JavaScript (server-rendered markup runs identically under `rack_test` at a fraction of the cost); fixtures built by driving the UI rather than by factories, which makes every consumer a browser spec and drags the whole race surface in with it; factories doing file or network IO by default, with no opt-out trait; `create` where `build_stubbed` would do; and the actual distribution of time — run with `--profile` and name the slowest files rather than guessing.
- **Low-value and duplicated tests** — examples that stub a collaborator and then assert only that the stub was called; examples re-testing Rails or a gem rather than application behavior; the same behavior asserted at three layers (controller *and* request *and* feature); near-duplicate examples differing only in a literal, which belong in a table-driven loop; and scenario names that do not describe what the body does (a misleading name hides the gap it implies is covered).

## Output format

For each finding output:
- **Severity**: Critical / High / Medium / Low / Info
- **Location**: `file_path:line_number` (spec or the untested source path)
- **Finding**: what gap exists
- **Impact**: regression risk
- **Fix**: a concrete spec outline/snippet proposal (described, not applied)

Group by severity. If clean, state so explicitly per check.
