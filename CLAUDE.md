# CLAUDE.md

## Project Overview

MilkSteak is a recipe tracker Rails app. Users can create recipes with ingredients, images, directions, and tags (cooking methods, courses, cultural influences, dietary restrictions). Recipes are browsable with tag-based filtering and pagination. Admins can import recipes from URLs or pasted text via AI extraction (Anthropic Claude).

New users sign up with an email and a unique public username; accounts require admin approval before they can sign in. Admins manage pending users via `/admin/users`.

## Tech Stack

- **Ruby 4.0.1** / **Rails 8.1**
- **PostgreSQL 16+** (dev: `milk_steak_development`, test: `milk_steak_test`)
- **Propshaft** asset pipeline with vendored jQuery/jQuery UI
- **Tailwind CSS v4** via `tailwindcss-rails` (no Node.js required)
- **Devise 5** for authentication (database_authenticatable, registerable, recoverable, rememberable, trackable, validatable, confirmable)
- **Pundit 2** for authorization (policy classes in `app/policies/`; approval gate stays a Devise authn concern, not a policy)
- **Active Storage** with S3 in production, local disk in dev/test
- **Solid Queue** (1.7) for background jobs (separate queue database in production; batch tables via `db/queue_schema.rb`)
- **Anthropic Claude** for AI recipe extraction
- **Simple Form** for form rendering
- **Redcarpet** for Markdown rendering (safe links, escaped HTML, autolinks)
- **will_paginate** for pagination

## System Dependencies

- **libvips** — required for Active Storage image variant processing (thumbnails, resizing)
  - macOS: `brew install vips`
  - Debian/Ubuntu: `sudo apt-get install libvips-dev`
- **Google Chrome** — required for feature specs (Selenium headless)

## Common Commands

```bash
# Run the full CI suite (brakeman, bundler-audit, rubocop, rspec)
bundle exec rake

# Run tests only
bundle exec rspec

# Run linter only
bundle exec rubocop

# Start development server (web + css watcher + job worker)
bin/dev

# Database setup
bin/setup
rails db:prepare

# Update README screenshots (requires bin/dev to be running)
bin/screenshots
```

## Project Structure

### Models
- `app/models/recipe.rb` — Core model with status workflow, tagging, nested attributes; delegates `email` and `username` to user (prefix: true); `source_text` capped at 50 kB. `Recipe.fuzzy_autocomplete_for` (and `Ingredient.unique_names`, `RecipeIngredient.unique_units`, `Recipe.unique_serving_units`) search published recipes only.
- `app/models/image.rb` — Active Storage attachment with type/size validation; variants: `:tiny` (32x32), `:thumb` (187x187), `:large` (800x600)
- `app/models/ingredient.rb` — Global, shared ingredient names (normalized lowercase on save, unique), linked to recipes via RecipeIngredient. `Ingredient.resolve_by_name` is the single create-or-match entry point used by both the recipe form and the AI importer; it rescues `RecordNotUnique` so a concurrent insert race resolves to the winner's row instead of 500ing. Deliberately non-raising, so an invalid name surfaces as a validation error on the parent recipe save rather than a 500
- `app/models/recipe_ingredient.rb` — Join model with quantity (max 10 chars), unit, descriptor, section; ordered via `acts_as_list` scoped by recipe and section; replaces `accepts_nested_attributes_for :ingredient` with a hand-rolled `ingredient_attributes=` setter that resolves via `Ingredient.resolve_by_name` and ignores any incoming `id` — the recipe form can never rename or duplicate an Ingredient, for any role. Presence of `recipe`/`ingredient` is enforced by `belongs_to` alone (the explicit `validates ... presence: true` pair was redundant and removed)
- `app/models/user.rb` — Devise user with `username` (unique, 3–30 chars, letters/numbers/underscores), `admin` flag, and `approved` flag. Key methods: `approved?` (always true for admins), `active_for_authentication?` (gates sign-in for unapproved users), `inactive_message` (returns `:pending_approval` symbol for Devise i18n). Pending admins bypass the approval gate — the admin flag is checked first. Also `:lockable` (10 failed attempts → lock, email unlock). `has_many :recipes, dependent: :destroy, strict_loading: false` so Devise's "Cancel my account" cascades to recipes/images (see Key Patterns).
- `app/models/ai_classifier_run.rb` — Persisted record of every AI pipeline call (RecipeTextExtractor, RecipeAiExtractor, RecipeAiApplier); stores adapter, model, system_prompt, user_prompt, raw_response, timing, success/failure. `belongs_to :recipe, optional: true` (FK `on_delete: :nullify`, so runs survive recipe deletion); `recipe_name` returns `"(recipe deleted)"` when the recipe is gone, and admin index/show views render that fallback instead of a dead link.
- `app/models/filter_set.rb` — PORO (ActiveModel::Model) for compound recipe filtering (tags, name, ingredients, author); author filter uses `users.username ilike ?` (case-insensitive partial match)
- `app/models/featured_image_chooser.rb` — PORO for selecting featured recipe images
- `app/models/tag_finder.rb` — PORO for querying tags by context

### Controllers
- `app/controllers/application_controller.rb` — Includes `Pundit::Authorization` and rescues `Pundit::NotAuthorizedError`: `show?` denials re-raise `ActiveRecord::RecordNotFound` (→ 404, no existence oracle), guests get redirected to sign-in, and any other logged-in denial gets `root_path` + `not_authorized` alert. `configure_permitted_parameters` permits `:username` on Devise sign_up; `require_logged_in_approved!` routes guests to sign-in and signs out unapproved users with the `pending_approval` alert (replaces the old `require_approved!`/`redirect_to_login`/`forbidden`); `autocomplete_query` helper returns nil for blank/non-String `q`, so autocompletes render `[]` instead of enumerating
- `app/controllers/recipes_controller.rb` — Main CRUD. The public index renders the full published feed for everyone (guests included): `Recipe.published.includes(...).recent.paginate(...)` filtered by `FilterSet` — it does **not** use `policy_scope` (published *is* the public access control), so guests can browse and use all tag/name/ingredient/author search without an account, and members see the same cookbook (their own drafts show only in the admin shell). Public show is open for published recipes; `new/create/edit/update` run under `require_logged_in_approved!` and use the `'admin'` layout. Every action authorizes (`authorize @recipe`, `authorize :recipe, :index?`) and strong params come from `RecipePolicy#permitted_attributes` (ingredient params are `:name` only, no `:id`, for every role — Ingredients are create-or-matched by name in `RecipeIngredient#ingredient_attributes=`, never renamed/duplicated). Keep destroyed via `policy_scope(Recipe).includes(...)` (unowned drafts get 404). Headless text ORACLE: `ensure_visible` style disclosure is gone; the no-existence oracle is preserved by `Rescuer: show? → RecordNotFound`. `page`/`per_page` clamped (`page` ≥ 1, `per_page` 1–48)
- `app/controllers/users/sessions_controller.rb` / `registrations_controller.rb` — Devise overrides that rate-limit `#create` (10 per 3 min for sessions, 10 per 10 min for registrations) via `rate_limit ... with: :rate_limited` returning 429 `devise.failure.too_many_requests`
- `app/controllers/admin/base_controller.rb` — `layout 'admin'`, `before_action :require_logged_in_approved!`, `after_action :verify_authorized`, and `require_admin!` (`authorize :site, :admin_area?`). Admin auth is a **policy** check, not a visibility shortcut
- `app/controllers/admin/recipes_controller.rb` — Admin + member shell. Index is `policy_scope(Recipe)` — admins see all, members see only their own (status-filter tabs and `group(:status)` counts computed on the whole scoped set so tabs are consistent); `find_recipe` is policy-scoped so acting on another user's recipe 404s before `publish?`/`reject?`/`reprocess?`/`destroy?` even runs. `destroy?` scoping lets members delete their **own** recipes
- `app/controllers/admin/magic_recipes_controller.rb` — AI recipe import (new, create); overrides `layout 'application'` (public shell) and `require_admin!`
- `app/controllers/admin/users_controller.rb` — User management via `require_admin!` + `authorize :user, :index?/:approve?`; index lists pending and approved non-admin users; approve patches `approved: true`
- `app/controllers/admin/ai_classifier_runs_controller.rb` — AI run history. Every query goes through `policy_scope(AiClassifierRun)` (runs of the visible recipe scope, so members only see their own runs read-only); show/rerun `find_run` is scoped (others' runs 404); rerun re-enqueues MagicRecipeJob and is admin-only (`authorize @run, :rerun?`)
- `app/controllers/autocompletes/` — JSON endpoints for tags, ingredients, units, serving units; all query **published recipes only** (no draft disclosure)

### Policies
- `app/policies/application_policy.rb` — Base class: `admin?` (boolean), `user`/`record` readers, no-op `Scope`
- `app/policies/recipe_policy.rb` — `index?` all; `show?` published or owner or admin; `new?`/`create?` any signed-in user; `edit?`/`update?`/`destroy?` owner or admin; `publish?`/`reject?`/`reprocess?`/`admin_fields?` admin only; `permitted_attributes` (all strong params, ingredient `:name` only, plus `status`/`source_url`/`source_text` for admins); `Scope` = admin → all, member → own, guest → published (governs the admin/management and AI-run surfaces — the public index renders `Recipe.published` directly and never calls `policy_scope`)
- `app/policies/ai_classifier_run_policy.rb` — `index?`/`show?` any signed-in user; `rerun?` admin; `Scope` reuses `RecipePolicy::Scope` so members only see runs of their own recipes
- `app/policies/user_policy.rb` — `index?`/`approve?` admin only
- `app/policies/site_policy.rb` — `admin_area?`/`magic?` admin only (used via `policy(:site)` for role-only checks in views/controllers)

### Services
- `app/services/safe_url_fetcher.rb` — SSRF-safe HTTP fetch. Resolves DNS, blocks internal/private/link-local ranges (`0.0.0.0/8`, `10/8`, `100.64/10`, `127/8`, `169.254/16` incl. AWS metadata, `172.16/12`, `192.168/16`, `::1`, `fc00::/7`, `fe80::/10`), raises `SafeUrlFetcher::BlockedAddressError`; max 5 redirects, timeouts (5s open / 15s read), `MAX_BYTES = 5.megabytes`. Test seam: `SafeUrlFetcher.addresses_for` / `blocked_address?`
- `app/services/recipe_ai_extractor.rb` — Sends source content to Anthropic API, returns parsed JSON; wraps text in `<untrusted_recipe_text>` delimiters (prompt-injection defense); `validate_result!` requires name+directions and an ingredients array (max 200)
- `app/services/recipe_ai_applier.rb` — Applies AI-extracted data to a Recipe (ingredients, tags, directions); caps ingredients at 200; ingredient names resolved via `Ingredient.resolve_by_name`. The apply body runs inside `Recipe.transaction`, nested **inside** `with_classifier_run` — `apply_ingredients` calls `destroy_all` before rebuilding, so without the transaction a later `save!` failure would strand the recipe with zero ingredients and `MagicRecipeJob`'s `retry_on` would repeat against the emptied set. The transaction is nested inside (not around) the run lifecycle so a rollback cannot erase the `AiClassifierRun` audit record
- `app/services/recipe_text_extractor.rb` — Fetches and extracts text/schema.org data from recipe URLs via `SafeUrlFetcher.fetch(@url)`

### Jobs
- `app/jobs/magic_recipe_job.rb` — Background job for AI recipe processing pipeline

### Key Views / Partials
- `app/views/layouts/admin.html.erb` — Dedicated admin layout: slim terra sidebar (`app/views/admin/_sidebar.html.erb`) with role-aware nav (Recipes + AI Runs for everyone; Magic Recipe and Users links and the "Admin" chip for admins via `policy(:site)`), plus flashes, footer, and scripts; selected explicitly via `layout "admin"` on `Admin::BaseController` (Rails does not auto-resolve `layouts/admin` for namespaced controllers — `_implied_layout_name` would look up `layouts/admin/recipes`)
- `app/views/recipes/_show_content.html.erb` — Publication-style recipe detail: title + metadata chips (prep/cook/makes/author), then the featured image, then two-column ingredients|directions on desktop, then tags strip and lightbox gallery. Author chip shows the username linked to the author filter; legacy accounts with a blank username fall back to the email rendered via `armored_email` (CSS-reverse scrape protection — reversed text in the DOM, flipped visually by the `.armored-email` rule in `app/assets/tailwind/application.css`), never the raw address
- `app/views/recipes/_control_panel.html.erb` — Role-aware toolbar on recipe#show, gated by `current_user == recipe.user || policy(:site).admin?`; renders Edit and (now, for owners too) Delete, plus admin-only status badge + grouped Publish/Reject/Reprocess buttons via `policy(recipe)`; uses shared `.btn` component classes
- `app/views/recipes/_recipe.html.erb` — Recipe card with square image crop and a corner time badge when `cooking_time` is present
- `app/views/application/_nav.html.erb` — Public header nav (rendered by the `application` layout): New Recipe + My recipes links for any signed-in user, the Admin link and a Magic Recipe link (🪄, to `new_admin_magic_recipe_path`) between Admin and the email/log-out pill, gated via `policy(:site).admin?`/`policy(:site).magic?`
- `app/views/recipes/_filter_set.html.erb` — Search form with collapsible `<details>` groups around the tag autocompletes (all open by default); each group's `<summary>` is the sole label — the inner inputs render `label: false` and point at the summary via `aria-labelledby` (ids `filter_<attribute>_summary`), so there's no duplicated visible label while inputs keep their accessible name
- `app/views/recipes/_tagged_attributes.html.erb` / `app/views/acts_as_taggable_on/tags/_tag.html.erb` — Tag chips, colored per context, linking to the matching filter
- `app/views/admin/recipes/index.html.erb` — Admin recipe index (scoped for members): page header with "New Recipe" CTA (the public recipe form), status-filter tab strip above the table, and grouped row actions (Publish/Reject/Reprocess/Edit with Delete separated, policy-gated); Author column renders `author_display` (`ApplicationHelper`) — username first, CSS-armored email fallback for blank usernames
- `app/views/admin/users/index.html.erb` — Pending and approved user lists with approve buttons
- `app/views/admin/ai_classifier_runs/` — AI run index (grouped by recipe) and show (full prompt/response detail)
- `app/views/devise/` — Custom Simple Form auth screens matching the sign-up card style (`max-w-md mx-auto p-6` + serif h2 + terra submit), all rendered through the public `application` layout: `sessions/new`, `passwords/new` + `passwords/edit`, `confirmations/new`, `registrations/new` + `registrations/edit`, and `shared/_links` (Log in/Sign up/Forgot password/Confirmation/Unlock links). The old `body.devise-*` CSS block styling the gem default `.field`/`.actions` markup has been removed
- `app/views/layouts/errors.html.erb` / `app/views/errors/show.html.erb` — Minimal branded error-page layout (terra-dark marble body + cream column + brand header, no nav/footer/DB/GA deps) and status-keyed copy for `ErrorsController`
- `app/controllers/errors_controller.rb` — Renders branded 400/404/406/422/500 pages via `config.exceptions_app` (see Config) and matching `get '/400|404|406|422|500'` routes; unknown statuses fall back to the 500 copy

### Config
- `config/application.rb` — Sets `config.exceptions_app` (routes status errors to `ErrorsController.action(:show)`, so even 4xx/5xx render the branded errors layout); adds Rack::Deflater and the security headers
- `config/initializers/content_security_policy.rb` — CSP enforced; `script_src` carries no `:unsafe_inline` (all app JS is external: `admin/magic_recipes/new.js`, `analytics.js`, `test_setup.js`), only `:self` + Google Analytics
- `config/initializers/acts_as_taggable_on.rb` — Force lowercase tags, auto-cleanup unused tags
- `config/initializers/devise.rb` — Configures `:lockable` (`lock_strategy = :failed_attempts`, `unlock_keys = [:email]`, `unlock_strategy = :email`, `maximum_attempts = 10`, `last_attempt_warning = true`)
- `config/initializers/host_check.rb` — Raises in production if `HOST` is not set (fail-fast on deploy)
- `lib/tasks/` — Custom rake tasks for brakeman, bundler-audit, rubocop

## Routes

- `root` → `recipes#index`
- `resources :recipes` — index, new, create, show, edit, update. No delete route (manual shell deletion happens at `admin/recipes`)
- `admin/users` — index, plus member route: approve (patch)
- `admin/recipes` — index, destroy, plus member routes: publish, reject, reprocess
- `admin/magic_recipes` — new, create (AI import)
- `admin/ai_classifier_runs` — index, show, plus member route: rerun (post)
- `devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }` — rate-limited Devise endpoints
- `autocompletes/` — index-only resources for cooking_methods, cultural_influences, courses, dietary_restrictions, serving_units, ingredient_units, ingredient_names
- `/up` — Rails 8 health check

## Recipe Status Workflow

Recipes have a `status` field with values: `draft`, `processing`, `processing_failed`, `review`, `published`, `rejected`.

- **Manual creation:** User creates a recipe directly → `published`
- **AI import (admin):** `draft` → `processing` → `review` (or `processing_failed`) → `published` / `rejected`
- `publishable?` — true when status is `review`
- `reprocessable?` — true when status is `processing_failed`

## Testing

- **RSpec** with FactoryBot, Shoulda Matchers, Capybara, Database Cleaner
- Factories in `spec/support/factories.rb`, validated via `spec/models/factories_spec.rb`
- Shared examples in `spec/support/shared_examples/`
- Policy specs in `spec/policies/` are plain RSpec (no pundit-matchers) — they assert the role matrix directly on policy booleans and `Scope#resolve`
- Feature specs use Selenium headless Chrome (`js: true`); default driver is `rack_test`
- `user_logs_in` (in `Features::SessionHelpers`) creates and logs in a regular user; `log_in_as(user)` logs in a pre-created user (use this when you need to supply your own user, e.g. an admin)
- WebMock disables external network calls in tests
- `strict_loading_by_default` enabled in test environment to catch N+1 queries
- Prefer `build_stubbed` over `create` in unit/controller specs for performance
- When stubbing `find_recipe`, stub `Recipe.includes` (not `Recipe.find`) since the controller chains `.includes(...).find(id)`
- User factory defaults: `approved: true`, auto-generated `username` (sequence `user1`, `user2`, …); use the `:pending` trait for `approved: false`; `:admin` trait sets `admin: true`
- The `sign_in_user` controller helper mocks `current_user` directly — it bypasses Devise auth entirely, so `active_for_authentication?` is not exercised in controller specs

## Linting & Security

- **RuboCop** with rubocop-rails, rubocop-rspec, rubocop-performance plugins
- `.rubocop_todo.yml` tracks existing offenses for incremental cleanup
- Auto-generated files excluded in `.rubocop.yml`: `config/puma.rb`, `db/queue_schema.rb`, `db/schema.rb`, `db/migrate/`
- **Brakeman** for Rails security scanning
- **Bundler Audit** for dependency vulnerability checking
- All three run as part of `bundle exec rake` (in order: brakeman, bundler-audit, rubocop, rspec)

## Auditing

The repo ships an **agent-based audit system** for cross-harness use (opencode, Claude CLI, Pi, and Copilot/Cursor via skills). It complements — not replaces — the static tools above and is **read-only** (agents never edit files; they report findings with `file_path:line_number`, severity, impact, and a proposed fix).

- **Portable knowledge** lives in `.github/skills/<topic>/SKILL.md` — eight audit skills: `security-audit` (folds in Brakeman), `accessibility-audit`, `performance-audit`, `compatibility-audit`, `rails-practices-audit` (folds in RuboCop), `data-integrity-audit`, `dependency-audit` (folds in Bundler Audit), and `test-quality-audit`.
- **Thin per-harness agents** point at those skills: `.opencode/agent/<topic>-auditor.md`, `.claude/agents/<topic>-auditor.md`, `.pi/agents/<topic>-auditor.md`, plus an `audit-orchestrator` in each. opencode registers the skill dir via `opencode.json` (`skills.paths`).
- **Invoke** with `/audit` (reads the harness-native `*.md` command in `.opencode/command/`, `.claude/commands/`, `.pi/commands/`): `/audit` runs all eight, `/audit security accessibility` runs a subset, `/audit --report` additionally writes `docs/audits/YYYY-MM-DD.md` (gitignored).
- Model is unset on all agents so they inherit the current session model; override per harness via native config.

When the auditing system changes, keep the skill bodies, the per-harness agents/commands, `opencode.json`, and this section in sync.

## Key Patterns

- Recipes use `acts_as_taggable_on` with four tag contexts, all force-lowercased with auto-cleanup of unused tags
- Nested attributes: Recipe accepts nested RecipeIngredients and Images
- RecipeIngredients ordered via `acts_as_list`, scoped by recipe and section
- `RecipeIngredient#quantity` is max 10 characters — AI prompts must enforce this; use digits/fractions/hyphens only (e.g. `"1 1/2"`, `"2-3"`, `"to taste"`)
- Ingredients are a global, shared table with **lowercase-normalized, unique names** (migration `20260830000003` collapsed existing mixed-case/duplicate rows; `20260901000000` added the unique index on `lower(name)` so the invariant is enforced by the DB, not just the callback). The recipe form and AI importer both resolve ingredients create-or-match by normalized name; no code path can rename or duplicate an Ingredient — admins included
- Image uploads validated for type (JPEG, PNG, WebP, AVIF, HEIC/HEIF) and size (max 10MB)
- Security headers in `config/application.rb`: X-Frame-Options, X-Content-Type-Options, X-XSS-Protection, Referrer-Policy, Permissions-Policy
- CSP enforced via `content_security_policy.rb`; `script_src` has no `:unsafe_inline` — the source-toggle script (`admin/magic_recipes/new.js`), the Google Analytics snippet (`analytics.js`, reads the tracking ID from a `data-tracking-id` attribute since Propshaft doesn't compile ERB in JS), and the test-only `$.fx.off` setup (`test_setup.js`) are all external assets
- Foreign key constraints on `images`, `recipe_ingredients`, and `recipes` tables, all `on_delete: :cascade` to match the models' `dependent: :destroy` (migration `20260901000000`). `ai_classifier_runs.recipe_id` stays `on_delete: :nullify` so runs outlive their recipes
- `User has_many :recipes, dependent: :destroy, strict_loading: false` — the cascade is what Devise's "Cancel my account" button promises ("permanently deletes your account, recipes, and images"). `:destroy` rather than `:delete_all` so each Image runs its Active Storage purge callback; a DB cascade alone would orphan the stored blobs. The association-level `strict_loading: false` overrides the owner's setting, since destroying inherently loads the association and `strict_loading_by_default` is on in test
- DB-level constraints backing model validations that `update_column`/`insert_all`/raw SQL would otherwise bypass: `CHECK` on `recipes.status` (matches `Recipe::STATUSES`), `CHECK` on `octet_length(recipes.source_text) <= 51200`, unique index on `ingredients(lower(name))`, and `NOT NULL` on `recipes.user_id`, `images.recipe_id`, plus every legacy timestamp column. Legacy `integer` FK columns were widened to `bigint` to match their primary keys
- Search performance indexes: `pg_trgm` extension enabled with GIN trigram indexes on `recipes(lower(name))`, `ingredients(lower(name))`, and `users(username)` for the substring `like`/`ilike` filter/autocomplete queries (see `FilterSet`, `Recipe.fuzzy_autocomplete_for`, and the autocomplete controllers); composite indexes on `recipes(user_id, status)` and `recipes(status, created_at)`; a unique index on `ingredients(name)` enforces one canonical row per ingredient name
- `Rack::Deflater` middleware for gzip compression
- Use `Recipe.includes(...)` for eager loading associations (not `Preloader`); image blobs are eager-loaded via `includes(images: { image_attachment: :blob })` in the recipes controller index/show
- Markdown rendered via Redcarpet with `safe_links_only` and `escape_html`
- Tagging associations exempted from strict loading (gem uses lazy loading internally)
- Pundit authorization: every recipes/admin action calls `authorize` and scoped indexes call `policy_scope` (recipes and admin controllers have `after_action :verify_authorized`; `verify_policy_scoped` is per-controller on the indexes that scope — except the public recipe index, which uses the explicit `Recipe.published` scope instead). `RecipePolicy::Scope` is the single source of truth for "management-visible recipes" (admin → all, member → own, guest → published) and `AiClassifierRunPolicy::Scope` builds on it, so members can never see other users' recipes or runs in the admin shell; the public cookbook index bypasses the scope entirely and shows `Recipe.published` to everyone. Symbol policies (`authorize :site, :admin_area?`) map to `SitePolicy`.
- Denied-action semantics: `show?` failures re-raise `ActiveRecord::RecordNotFound` (uniform 404 for guests *and* logged-in members — no existence oracle); guests get redirected to sign-in; any other logged-in member denial redirects to `root_path` with the `not_authorized` alert (locale key in `config/locales/en.yml`). Policy-scoped lookups also produce a 404 (`policy_scope(...).find`), so acting on another user's recipe/runs 404s before the action's `authorize` even runs.
- Devise approval pattern: override `active_for_authentication?` and `inactive_message` on User; the `:pending_approval` symbol maps to `devise.failure.pending_approval` in `config/locales/devise.en.yml`; admins bypass the gate via `approved?` short-circuiting on `admin?`. The approval gate stays an authn concern (`require_logged_in_approved!`), never a policy.
- SSRF hardening: all outbound HTTP uses `SafeUrlFetcher.fetch` (never raw `Net::HTTP`/`URI.open`), which resolves DNS and blocks internal/private/link-local IPs before connecting. Test seam: stub `SafeUrlFetcher.addresses_for` to a public IP.
- Login/registration hardening: Devise `:lockable` locks accounts after 10 failed attempts (email unlock); `users/sessions` and `users/registrations` controllers `rate_limit` `#create` (10/3min and 10/10min) returning 429 `devise.failure.too_many_requests`.
- Draft disclosure: every autocomplete query (`autocomplete_query` helper) targets **published** recipes only; blank/non-String `q` yields `[]`, never a full enumeration.
- AI pipeline observability: every call to RecipeTextExtractor, RecipeAiExtractor, and RecipeAiApplier creates an `AiClassifierRun` record before the operation starts (`success: false`), then updates it on completion; viewable at `/admin/ai_classifier_runs`. The extractor also records LLM token usage (`input_tokens`/`output_tokens`) from the RubyLLM Message's `tokens`, and the Anthropic `request_id` from the raw response body (`message.raw.body['id']` — note `Message#raw` is a `Faraday::Response`, so use `.body` before `dig`); `total_tokens` sums the tokens.

## Environment Variables

Development uses `dotenv-rails` with a `.env` file (see `.sample.env` for required vars).

| Variable | Environment | Purpose |
|---|---|---|
| `SECRET_KEY_BASE` | All | Rails secret key (generate with `bundle exec rake secret`) |
| `ANTHROPIC_API_KEY` | All | AI recipe import |
| `ANTHROPIC_MODEL` | All | Claude model for extraction (default: `claude-haiku-4-5-20251001`) |
| `DEFAULT_SENDER` | All | Devise mailer from address |
| `APP_NAME` | All | Display name in layout (default: "Recipes") |
| `HOST` | Dev/Prod | Mailer URL host (default: `localhost:3000`) |
| `DATABASE_URL` | Production | PostgreSQL connection string |
| `AWS_ACCESS_KEY_ID` | Production | S3 file storage |
| `AWS_SECRET_ACCESS_KEY` | Production | S3 file storage |
| `S3_BUCKET_NAME` | Production | S3 bucket name |
| `AWS_REGION` | Production | S3 region (default: `us-east-1`) |
| `SMTP_ADDRESS` | Production | Email delivery |
| `SMTP_DOMAIN` | Production | Email delivery |
| `SMTP_USERNAME` | Production | Email delivery |
| `SMTP_PASSWORD` | Production | Email delivery |
| `GOOGLE_TRACKING_ID` | Production | Analytics (optional) |
| `RAILS_MAX_THREADS` | Production | Puma thread pool (default: 5) |
| `WEB_CONCURRENCY` | Production | Puma worker count (default: 2) |
| `TIMEOUT_IN_SECONDS` | Production | Rack timeout (default: 5) |
| `RAILS_LOG_LEVEL` | Production | Log verbosity (default: `info`) |

## Before Creating a PR

**Always run the full suite and confirm it passes before pushing or opening a PR:**

```bash
bin/rake
```

This runs in order: bundler-audit (with DB update), brakeman, rubocop, rspec. All four must be green. Do not create a PR if any step fails — fix the issue locally first. This catches CVEs, security warnings, lint offenses, and test failures before CI sees them.

**Git branch policy:** force-pushing (rewriting history) is allowed on any pre-merge feature branch — use `git push --force-with-lease`. Never force-push to `main` (the default branch) or rewrite any history that touches it.

**Always include a documentation update sweep in the same PR.** Before pushing or opening a PR, review the change and update anything it touches in:
- `CLAUDE.md` (and any other agentic instruction files, e.g. `AGENTS.md`) — project overview, tech stack, project structure, routes, workflow, environment variables, key patterns, testing notes, and commands.
- `README.md` — features, setup, testing, tech stack, architecture, and screenshots.
- `db/schema.rb` / migrations if the change adds/alters tables, columns, indexes, or constraints.

When the change introduces or renames models, controllers, services, jobs, routes, env vars, migrations, or visible behavior (e.g. UI text, screenshots), the corresponding section(s) in these docs must be updated to match — otherwise the docs drift and mislead future agents. If nothing is affected, no doc change is needed, but verify rather than assume. Re-run `bin/rake` after any edits (check that doc/markdown changes don't affect lint) so the PR is green before it ships.

## CI

GitHub Actions on push to master and all PRs. Runs PostgreSQL 16 service container, Ruby 4.0.1, and `bundle exec rake`.
