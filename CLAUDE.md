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
- `app/models/ingredient.rb` — Ingredient names, linked to recipes via RecipeIngredient
- `app/models/recipe_ingredient.rb` — Join model with quantity (max 10 chars), unit, descriptor, section; ordered via `acts_as_list` scoped by recipe and section
- `app/models/user.rb` — Devise user with `username` (unique, 3–30 chars, letters/numbers/underscores), `admin` flag, and `approved` flag. Key methods: `approved?` (always true for admins), `active_for_authentication?` (gates sign-in for unapproved users), `inactive_message` (returns `:pending_approval` symbol for Devise i18n). Pending admins bypass the approval gate — the admin flag is checked first. Also `:lockable` (10 failed attempts → lock, email unlock).
- `app/models/ai_classifier_run.rb` — Persisted record of every AI pipeline call (RecipeTextExtractor, RecipeAiExtractor, RecipeAiApplier); stores adapter, model, system_prompt, user_prompt, raw_response, timing, success/failure
- `app/models/filter_set.rb` — PORO (ActiveModel::Model) for compound recipe filtering (tags, name, ingredients, author); author filter uses `users.username ilike ?` (case-insensitive partial match)
- `app/models/featured_image_chooser.rb` — PORO for selecting featured recipe images
- `app/models/tag_finder.rb` — PORO for querying tags by context

### Controllers
- `app/controllers/application_controller.rb` — `configure_permitted_parameters` permits `:username` on Devise sign_up; `require_approved!` signs out and redirects any authenticated user whose `approved?` returns false; `autocomplete_query` helper returns nil for blank/non-String `q`, so autocompletes render `[]` instead of enumerating
- `app/controllers/recipes_controller.rb` — Main CRUD with ownership-based authorization; `require_approved!` fires before new/create/edit/update; `ensure_visible` raises `ActiveRecord::RecordNotFound` (→ 404) for guests on non-published recipes (no existence oracle); `page`/`per_page` clamped (`page` ≥ 1, `per_page` 1–48); nested `ingredient_attributes` only exposes `:id` to admins so non-admins can't rename shared ingredients
- `app/controllers/users/sessions_controller.rb` / `registrations_controller.rb` — Devise overrides that rate-limit `#create` (10 per 3 min for sessions, 10 per 10 min for registrations) via `rate_limit ... with: :rate_limited` returning 429 `devise.failure.too_many_requests`
- `app/controllers/admin/base_controller.rb` — Admin auth via `current_user&.admin?` before_action
- `app/controllers/admin/recipes_controller.rb` — Admin recipe management (publish, reject, reprocess, destroy)
- `app/controllers/admin/magic_recipes_controller.rb` — AI recipe import (new, create)
- `app/controllers/admin/users_controller.rb` — User management: index lists pending and approved non-admin users; approve patches `approved: true`
- `app/controllers/admin/ai_classifier_runs_controller.rb` — AI run history with filtering, pagination, and per-recipe grouping; rerun action re-enqueues MagicRecipeJob
- `app/controllers/autocompletes/` — JSON endpoints for tags, ingredients, units, serving units; all query **published recipes only** (no draft disclosure)

### Services
- `app/services/safe_url_fetcher.rb` — SSRF-safe HTTP fetch. Resolves DNS, blocks internal/private/link-local ranges (`0.0.0.0/8`, `10/8`, `100.64/10`, `127/8`, `169.254/16` incl. AWS metadata, `172.16/12`, `192.168/16`, `::1`, `fc00::/7`, `fe80::/10`), raises `SafeUrlFetcher::BlockedAddressError`; max 5 redirects, timeouts (5s open / 15s read), `MAX_BYTES = 5.megabytes`. Test seam: `SafeUrlFetcher.addresses_for` / `blocked_address?`
- `app/services/recipe_ai_extractor.rb` — Sends source content to Anthropic API, returns parsed JSON; wraps text in `<untrusted_recipe_text>` delimiters (prompt-injection defense); `validate_result!` requires name+directions and an ingredients array (max 200)
- `app/services/recipe_ai_applier.rb` — Applies AI-extracted data to a Recipe (ingredients, tags, directions); caps ingredients at 200
- `app/services/recipe_text_extractor.rb` — Fetches and extracts text/schema.org data from recipe URLs via `SafeUrlFetcher.fetch(@url)`

### Jobs
- `app/jobs/magic_recipe_job.rb` — Background job for AI recipe processing pipeline

### Key Views / Partials
- `app/views/recipes/_control_panel.html.erb` — Role-aware action bar on recipe#show; renders for the recipe owner (Edit) or any admin (status badge + Edit + Publish/Reject/Reprocess/Delete gated on workflow state)
- `app/views/recipes/_show_content.html.erb` — Recipe detail; author shown as `user_username` (not email), linked to author filter
- `app/views/admin/recipes/index.html.erb` — Admin recipe list with unified status-filter/action bar; nav bar includes Users and AI Runs links
- `app/views/admin/users/index.html.erb` — Pending and approved user lists with approve buttons
- `app/views/admin/ai_classifier_runs/` — AI run index (grouped by recipe) and show (full prompt/response detail)
- `app/views/devise/registrations/new.html.erb` — Custom registration form that includes the username field (Simple Form)

### Config
- `config/initializers/content_security_policy.rb` — CSP enforced
- `config/initializers/acts_as_taggable_on.rb` — Force lowercase tags, auto-cleanup unused tags
- `config/initializers/devise.rb` — Configures `:lockable` (`lock_strategy = :failed_attempts`, `unlock_keys = [:email]`, `unlock_strategy = :email`, `maximum_attempts = 10`, `last_attempt_warning = true`)
- `config/initializers/host_check.rb` — Raises in production if `HOST` is not set (fail-fast on deploy)
- `lib/tasks/` — Custom rake tasks for brakeman, bundler-audit, rubocop

## Routes

- `root` → `recipes#index`
- `resources :recipes` — index, new, create, show, edit, update (no destroy for non-admin)
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

## Key Patterns

- Recipes use `acts_as_taggable_on` with four tag contexts, all force-lowercased with auto-cleanup of unused tags
- Nested attributes: Recipe accepts nested RecipeIngredients and Images
- RecipeIngredients ordered via `acts_as_list`, scoped by recipe and section
- `RecipeIngredient#quantity` is max 10 characters — AI prompts must enforce this; use digits/fractions/hyphens only (e.g. `"1 1/2"`, `"2-3"`, `"to taste"`)
- Image uploads validated for type (JPEG, PNG, WebP, AVIF, HEIC/HEIF) and size (max 10MB)
- Security headers in `config/application.rb`: X-Frame-Options, X-Content-Type-Options, X-XSS-Protection, Referrer-Policy, Permissions-Policy
- CSP enforced via `content_security_policy.rb`
- Foreign key constraints on `images`, `recipe_ingredients`, and `recipes` tables
- `Rack::Deflater` middleware for gzip compression
- Use `Recipe.includes(...)` for eager loading associations (not `Preloader`)
- Markdown rendered via Redcarpet with `safe_links_only` and `escape_html`
- Tagging associations exempted from strict loading (gem uses lazy loading internally)
- Devise approval pattern: override `active_for_authentication?` and `inactive_message` on User; the `:pending_approval` symbol maps to `devise.failure.pending_approval` in `config/locales/devise.en.yml`; admins bypass the gate via `approved?` short-circuiting on `admin?`
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

**Always include a documentation update sweep in the same PR.** Before pushing or opening a PR, review the change and update anything it touches in:
- `CLAUDE.md` (and any other agentic instruction files, e.g. `AGENTS.md`) — project overview, tech stack, project structure, routes, workflow, environment variables, key patterns, testing notes, and commands.
- `README.md` — features, setup, testing, tech stack, architecture, and screenshots.
- `db/schema.rb` / migrations if the change adds/alters tables, columns, indexes, or constraints.

When the change introduces or renames models, controllers, services, jobs, routes, env vars, migrations, or visible behavior (e.g. UI text, screenshots), the corresponding section(s) in these docs must be updated to match — otherwise the docs drift and mislead future agents. If nothing is affected, no doc change is needed, but verify rather than assume. Re-run `bin/rake` after any edits (check that doc/markdown changes don't affect lint) so the PR is green before it ships.

## CI

GitHub Actions on push to master and all PRs. Runs PostgreSQL 16 service container, Ruby 4.0.1, and `bundle exec rake`.
