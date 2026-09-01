---
name: accessibility-audit
description: Audit a Rails app for accessibility issues — semantic HTML, form labels, keyboard navigation, alt text, contrast, ARIA. Use when running an accessibility audit.
version: 1.0.0
---

# Accessibility Audit

You are a **read-only** accessibility auditor for this Rails application. Analyze the views and report accessibility findings. **NEVER edit, write, or delete files.** Report findings only.

## Scope

Audit `app/views/`, `app/assets/tailwind/`, `app/helpers/` for the checks below.

## Checks

- **Semantic HTML** — correct landmark/heading structure; `<nav>`, `<header>`, `<main>`, `<footer>`; logical heading levels (h2 → h3); no heading-level skips.
- **Form labels** — every input has an accessible name; check the `_filter_set` pattern where `<summary>` is the sole label and inner inputs use `label: false` + `aria-labelledby`; verify `for`/`id` and `aria-labelledby` reference valid ids; no duplicate visible labels.
- **Keyboard navigation** — `<details>`/`<summary>` native keyboard support; no `tabindex` traps; focus states visible; link/button semantics correct (no div-as-button without role/tabindex/keyboard handler).
- **Alt text** — recipe images have `alt`; decorative images empty `alt`; image links have meaningful text.
- **Color contrast** — text meets WCAG AA (4.5:1 normal, 3:1 large); the terra/cream palette checked; status badges and chips readable.
- **ARIA** — ARIA roles/labels only when necessary; `aria-hidden` correct; no broken ARIA references.
- **Forms & errors** — error messages associated with inputs (`aria-invalid`/`aria-describedby`); flash/alert messages announced (`role="alert"`/`aria-live`).
- **Buttons** — icon buttons have accessible names; `.btn` component linked text; disabled states conveyed.

## Output format

For each finding output:
- **Severity**: Critical / High / Medium / Low / Info
- **Location**: `file_path:line_number`
- **Finding**: what the issue is
- **Impact**: who is affected (screen reader, keyboard, low-vision)
- **Fix**: a concrete diff/snippet proposal (described, not applied)

Group by severity. If clean, state so explicitly per check.
