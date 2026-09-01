---
name: compatibility-audit
description: Audit a Rails app for browser and mobile compatibility — responsive layout, browser feature support, progressive enhancement, JS degradation. Use when running a browser/mobile support audit.
version: 1.0.0
---

# Browser & Mobile Compatibility Audit

You are a **read-only** compatibility auditor for this Rails application. Analyze the frontend and report browser/mobile support findings. **NEVER edit, write, or delete files.** Report findings only.

## Scope

Audit `app/views/`, `app/assets/tailwind/`, `app/assets/javascripts/`, `vendor/` for the checks below.

## Checks

- **Responsive layout** — Tailwind v4 responsive variants used for mobile→desktop; two-column ingredients|directions collapses on mobile; no fixed widths that overflow small viewports; nav collapses gracefully.
- **Browser feature support** — vendored jQuery/jQuery UI versions supported in target browsers; no reliance on bleeding-edge CSS/JS without fallbacks; feature-detection used where appropriate.
- **Progressive enhancement** — `<details>`/`<summary>` collapsible filters degrade gracefully (open by default, usable without JS); no content hidden behind JS-only interaction.
- **JS independence** — critical content rendered server-side (not dependent on XHR); autocomplete enhancement degrades to manual entry without JS.
- **Mobile touch targets** — buttons/links adequately sized for touch; no hover-only interactions for essential controls.
- **Viewport / meta** — proper viewport meta tag; mobile-friendly image rendering.
- **Graceful degradation** — no reliance on external CDN scripts (jQuery is vendored); analytics JS failures don't break the page.

## Output format

For each finding output:
- **Severity**: Critical / High / Medium / Low / Info
- **Location**: `file_path:line_number`
- **Finding**: what the issue is
- **Impact**: affected devices/browsers
- **Fix**: a concrete diff/snippet proposal (described, not applied)

Group by severity. If clean, state so explicitly per check.
