# CLAUDE.md

## Project Overview

MilkSteak is a recipe tracker Rails app. Users can create recipes with ingredients, images, directions, and tags (cooking methods, courses, cultural influences, dietary restrictions). Recipes are browsable with tag-based filtering and pagination. Admins can import recipes from URLs or pasted text via AI extraction (Anthropic Claude).

New users sign up with an email and a unique public username; accounts require admin approval before they can sign in. Admins manage pending users via `/admin/users`.

## Tech Stack

- **Ruby 4.0.1** / **Rails 8.0**
- **PostgreSQL 16+** (dev: `milk_steak_development`, test: `milk_steak_test`)
- **Propshaft** asset pipeline with vendored jQuery/jQuery UI
- **Tailwind CSS v4** via `tailwindcss-rails` (no Node.js required)
- **Devise** for authentication (database_authenticatable, registerable, recoverable, rememberable, trackable, validatable, confirmable)
- **Active Storage** with S3 in production, local disk in dev/test
- **Solid Queue** for background jobs (separate queue database in production)
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
- `app/models/recipe.rb` — Core model with status workflow, tagging, nested attributes; delegates `email` and `username` to user (prefix: true)
- `app/models/image.rb` — Active Storage attachment with type/size validation; variants: `:tiny` (32x32), `:thumb` (187x187), `:large` (800x600)
- `app/models/ingredient.rb` — Ingredient names, linked to recipes via RecipeIngredient
- `app/models/recipe_ingredient.rb` — Join model with quantity (max 10 chars), unit, descriptor, section; ordered via `acts_as_list` scoped by recipe and section
- `app/models/user.rb` — Devise user with `username` (unique, 3–30 chars, letters/numbers/underscores), `admin` flag, and `approved` flag. Key methods: `approved?` (always true for admins), `active_for_authentication?` (gates sign-in for unapproved users), `inactive_message` (returns `:pending_approval` symbol for Devise i18n). Pending admins bypass the approval gate — the admin flag is checked first.
- `app/models/ai_classifier_run.rb` — Persisted record of every AI pipeline call (RecipeTextExtractor, RecipeAiExtractor, RecipeAiApplier); stores adapter, model, system_prompt, user_prompt, raw_response, timing, success/failure
- `app/models/filter_set.rb` — PORO (ActiveModel::Model) for compound recipe filtering (tags, name, ingredients, author); author filter uses `users.username ilike ?` (case-insensitive partial match)
- `app/models/featured_image_chooser.rb` — PORO for selecting featured recipe images
- `app/models/tag_finder.rb` — PORO for querying tags by context

### Controllers
- `app/controllers/application_controller.rb` — `configure_permitted_parameters` permits `:username` on Devise sign_up; `require_approved!` signs out and redirects any authenticated user whose `approved?` returns false
- `app/controllers/recipes_controller.rb` — Main CRUD with ownership-based authorization; `require_approved!` fires before new/create/edit/update
- `app/controllers/admin/base_controller.rb` — Admin auth via `current_user&.admin?` before_action
- `app/controllers/admin/recipes_controller.rb` — Admin recipe management (publish, reject, reprocess, destroy)
- `app/controllers/admin/magic_recipes_controller.rb` — AI recipe import (new, create)
- `app/controllers/admin/users_controller.rb` — User management: index lists pending and approved non-admin users; approve patches `approved: true`
- `app/controllers/admin/ai_classifier_runs_controller.rb` — AI run history with filtering, pagination, and per-recipe grouping; rerun action re-enqueues MagicRecipeJob
- `app/controllers/autocompletes/` — JSON endpoints for tags, ingredients, units, serving units

### Services
- `app/services/recipe_ai_extractor.rb` — Sends source content to Anthropic API, returns parsed JSON
- `app/services/recipe_ai_applier.rb` — Applies AI-extracted data to a Recipe (ingredients, tags, directions)
- `app/services/recipe_text_extractor.rb` — Fetches and extracts text/schema.org data from recipe URLs

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
- `lib/tasks/` — Custom rake tasks for brakeman, bundler-audit, rubocop

## Routes

- `root` → `recipes#index`
- `resources :recipes` — index, new, create, show, edit, update (no destroy for non-admin)
- `admin/users` — index, plus member route: approve (patch)
- `admin/recipes` — index, destroy, plus member routes: publish, reject, reprocess
- `admin/magic_recipes` — new, create (AI import)
- `admin/ai_classifier_runs` — index, show, plus member route: rerun (post)
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
- AI pipeline observability: every call to RecipeTextExtractor, RecipeAiExtractor, and RecipeAiApplier creates an `AiClassifierRun` record before the operation starts (`success: false`), then updates it on completion; viewable at `/admin/ai_classifier_runs`

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

## CI

GitHub Actions on push to master and all PRs. Runs PostgreSQL 16 service container, Ruby 4.0.1, and `bundle exec rake`.

Always run `bin/rake` locally and confirm it passes before creating a PR.
