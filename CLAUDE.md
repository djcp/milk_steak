# CLAUDE.md

## Project Overview

MilkSteak is a recipe tracker Rails app. Users can create recipes with ingredients, images, directions, and tags (cooking methods, courses, cultural influences, dietary restrictions). Recipes are browsable with tag-based filtering and pagination. Admins can import recipes from URLs or pasted text via AI extraction (Anthropic Claude).

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
```

## Project Structure

### Models
- `app/models/recipe.rb` — Core model with status workflow, tagging, nested attributes
- `app/models/image.rb` — Active Storage attachment with type/size validation; variants: `:tiny` (32x32), `:thumb` (187x187), `:large` (800x600)
- `app/models/ingredient.rb` — Ingredient names, linked to recipes via RecipeIngredient
- `app/models/recipe_ingredient.rb` — Join model with quantity, unit, section; ordered via `acts_as_list` scoped by recipe and section
- `app/models/user.rb` — Devise user with `admin?` flag
- `app/models/filter_set.rb` — PORO (ActiveModel::Model) for compound recipe filtering (tags, name, ingredients, author)
- `app/models/featured_image_chooser.rb` — PORO for selecting featured recipe images
- `app/models/tag_finder.rb` — PORO for querying tags by context

### Controllers
- `app/controllers/recipes_controller.rb` — Main CRUD with ownership-based authorization
- `app/controllers/admin/base_controller.rb` — Admin auth via `current_user&.admin?` before_action
- `app/controllers/admin/recipes_controller.rb` — Admin recipe management (publish, reject, reprocess, destroy)
- `app/controllers/admin/magic_recipes_controller.rb` — AI recipe import (new, create)
- `app/controllers/autocompletes/` — JSON endpoints for tags, ingredients, units, serving units

### Services
- `app/services/recipe_ai_extractor.rb` — Sends source content to Anthropic API, returns parsed JSON
- `app/services/recipe_ai_applier.rb` — Applies AI-extracted data to a Recipe (ingredients, tags, directions)
- `app/services/recipe_text_extractor.rb` — Fetches and extracts text/schema.org data from recipe URLs

### Jobs
- `app/jobs/magic_recipe_job.rb` — Background job for AI recipe processing pipeline

### Key Views / Partials
- `app/views/recipes/_control_panel.html.erb` — Role-aware action bar on recipe#show; renders for the recipe owner (Edit) or any admin (status badge + Edit + Publish/Reject/Reprocess/Delete gated on workflow state)
- `app/views/admin/recipes/index.html.erb` — Admin recipe list with unified status-filter/action bar

### Config
- `config/initializers/content_security_policy.rb` — CSP enforced
- `config/initializers/acts_as_taggable_on.rb` — Force lowercase tags, auto-cleanup unused tags
- `lib/tasks/` — Custom rake tasks for brakeman, bundler-audit, rubocop

## Routes

- `root` → `recipes#index`
- `resources :recipes` — index, new, create, show, edit, update (no destroy for non-admin)
- `admin/recipes` — index, destroy, plus member routes: publish, reject, reprocess
- `admin/magic_recipes` — new, create (AI import)
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
- Image uploads validated for type (JPEG, PNG, WebP, AVIF, HEIC/HEIF) and size (max 10MB)
- Security headers in `config/application.rb`: X-Frame-Options, X-Content-Type-Options, X-XSS-Protection, Referrer-Policy, Permissions-Policy
- CSP enforced via `content_security_policy.rb`
- Foreign key constraints on `images`, `recipe_ingredients`, and `recipes` tables
- `Rack::Deflater` middleware for gzip compression
- Use `Recipe.includes(...)` for eager loading associations (not `Preloader`)
- Markdown rendered via Redcarpet with `safe_links_only` and `escape_html`
- Tagging associations exempted from strict loading (gem uses lazy loading internally)

## Environment Variables

Development uses `dotenv-rails` with a `.env` file (see `.sample.env` for required vars).

| Variable | Environment | Purpose |
|---|---|---|
| `SECRET_KEY_BASE` | All | Rails secret key (generate with `bundle exec rake secret`) |
| `ANTHROPIC_API_KEY` | All | AI recipe import |
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
