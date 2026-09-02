require 'spec_helper'

# strict_loading_by_default is on in the test environment, so rendering a fully
# populated recipe through the real views fails loudly if the controller stops
# preloading something the view touches.
#
# The query-count specs assert *invariance to collection size* rather than an
# absolute budget: a page showing more recipes/ingredients/images must cost the
# same number of queries as one showing fewer. An absolute number would drift
# with unrelated changes; invariance fails only for a genuine N+1.
describe 'Recipe eager loading', type: :request do
  # Counts real queries, ignoring schema reflection and transaction bookkeeping.
  def queries_for(&)
    count = 0
    counter = lambda do |_name, _start, _finish, _id, payload|
      next if payload[:name] == 'SCHEMA'
      next if payload[:sql].match?(/\A\s*(BEGIN|COMMIT|ROLLBACK|SAVEPOINT|RELEASE)/i)

      count += 1
    end

    ActiveSupport::Notifications.subscribed(counter, 'sql.active_record', &)
    count
  end

  # Tags are given in every context for both sizes, because each *non-empty*
  # context costs one extra `tags` lookup. Varying which contexts are populated
  # would change the count for a structural reason and mask a real N+1.
  def published_recipe(ingredients:, images:, tags_per_context:)
    create(:recipe, status: 'published').tap do |recipe|
      ingredients.times { create(:recipe_ingredient, recipe: recipe) }
      images.times { create(:image, recipe: recipe) }
      recipe.cooking_method_list = Array.new(tags_per_context) { generate(:cooking_method) }
      recipe.cultural_influence_list = Array.new(tags_per_context) { generate(:cultural_influence) }
      recipe.course_list = Array.new(tags_per_context) { generate(:course) }
      recipe.dietary_restriction_list = Array.new(tags_per_context) { generate(:dietary_restriction) }
      recipe.save!
    end
  end

  it 'renders a fully populated recipe without tripping strict loading' do
    recipe = published_recipe(ingredients: 2, images: 2, tags_per_context: 2)

    get recipe_path(recipe)

    expect(response).to be_successful
    expect(response.body).to include(recipe.name)
  end

  it 'costs the same number of queries however much a recipe contains' do
    small = published_recipe(ingredients: 1, images: 1, tags_per_context: 1)
    large = published_recipe(ingredients: 6, images: 3, tags_per_context: 4)

    get recipe_path(small) # warm lazily-initialised constants

    expect(queries_for { get recipe_path(large) })
      .to eq(queries_for { get recipe_path(small) })
  end

  it 'costs the same number of queries however many recipes the index lists' do
    published_recipe(ingredients: 1, images: 1, tags_per_context: 1)

    get root_path # warm up, and establish the one-recipe baseline
    baseline = queries_for { get root_path }

    4.times { published_recipe(ingredients: 2, images: 1, tags_per_context: 1) }

    # This passes with or without today's :user preload, because the card does
    # not currently render the author. It is a guard against the regression the
    # audit flagged as latent: the moment a card touches un-preloaded data, this
    # spec (and strict loading) fails instead of shipping an N+1 to production,
    # where strict_loading_by_default is off. Verified by adding author output
    # to the card with the preload removed -- StrictLoadingViolationError.
    expect(queries_for { get root_path }).to eq(baseline)
  end
end
