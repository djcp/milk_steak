# CLAUDE.md

## Project Overview

MilkSteak is a recipe tracker Rails app (deployed at eclecticrecip.es). Users can create recipes with ingredients, images, directions, and tags (cooking methods, courses, cultural influences, dietary restrictions). Recipes are browsable with tag-based filtering and pagination.

## Tech Stack

- **Ruby 3.4.1** / **Rails 8.0**
- **PostgreSQL** (dev: `milk_steak_development`, test: `milk_steak_test`)
- **Sprockets** asset pipeline with jQuery/jQuery UI
- **DartSass** (Bourbon, Bitters, Neat for styling)
- **Devise** for authentication
- **Active Storage** with S3 in production, local disk in dev/test

## System Dependencies

- **libvips** — required for Active Storage image variant processing (thumbnails, resizing)
  - macOS: `brew install vips`
  - Debian/Ubuntu: `sudo apt-get install libvips-dev`

## Common Commands

```bash
# Run the full CI suite (brakeman, bundler-audit, rubocop, rspec)
bundle exec rake

# Run tests only
bundle exec rspec

# Run linter only
bundle exec rubocop

# Start development server
bin/dev

# Database setup
bin/setup
rails db:prepare
```

## Project Structure

- `app/models/filter_set.rb` — PORO for compound recipe filtering (tags, name, ingredients, author)
- `app/models/featured_image_chooser.rb` — PORO for selecting featured recipe images
- `app/controllers/recipes_controller.rb` — Main controller with ownership-based authorization
- `app/controllers/autocompletes/` — Autocomplete endpoints for tags, ingredients, units
- `config/initializers/content_security_policy.rb` — CSP in report-only mode
- `lib/tasks/` — Custom rake tasks for brakeman, bundler-audit, rubocop

## Testing

- **RSpec** with FactoryBot, Shoulda Matchers, Capybara, Database Cleaner
- Factories in `spec/support/factories.rb`, validated via `spec/models/factories_spec.rb`
- Shared examples in `spec/support/shared_examples/`
- Feature specs use Selenium WebDriver
- WebMock disables external network calls in tests

## Linting & Security

- **RuboCop** with rubocop-rails, rubocop-rspec, rubocop-performance plugins
- `.rubocop_todo.yml` tracks existing offenses for incremental cleanup
- **Brakeman** for Rails security scanning
- **Bundler Audit** for dependency vulnerability checking
- All three run as part of `bundle exec rake`

## Key Patterns

- Recipes use `acts_as_taggable_on` with four tag contexts, all lowercased automatically
- Nested attributes: Recipe accepts nested RecipeIngredients and Images
- RecipeIngredients are ordered via `acts_as_list`
- Image uploads validated for type (JPEG, PNG, WebP, AVIF, HEIC) and size (max 10MB)
- Security headers set in `config/application.rb` (X-Frame-Options, X-Content-Type-Options, etc.)

## Environment Variables

Development uses `dotenv-rails` with a `.env` file (see `.sample.env` for required vars).

**Production-only:**
- `RDS_DB_NAME`, `RDS_USERNAME`, `RDS_PASSWORD`, `RDS_HOSTNAME`, `RDS_PORT` — database
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `S3_BUCKET_NAME`, `AWS_REGION` — file storage
- `SMTP_ADDRESS`, `SMTP_DOMAIN`, `SMTP_PASSWORD`, `SMTP_USERNAME` — email
- `GOOGLE_TRACKING_ID` — analytics (optional)

## CI

GitHub Actions on push to master and all PRs. Runs PostgreSQL 16 service container, Ruby 3.4.1, and `bundle exec rake`.
