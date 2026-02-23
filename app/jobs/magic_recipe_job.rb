class MagicRecipeJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(recipe_id)
    recipe = Recipe.find(recipe_id)
    recipe.strict_loading!(false)
    recipe.update!(status: 'processing')

    text = extract_text(recipe)
    data = RecipeAiExtractor.extract(text, recipe: recipe)
    RecipeAiApplier.apply(recipe, data)

    recipe.update!(status: 'review')
  rescue StandardError
    recipe&.update_columns(status: 'processing_failed') # rubocop:disable Rails/SkipsModelValidations
    raise
  end

  private

  def extract_text(recipe)
    if recipe.source_url.present?
      RecipeTextExtractor.from_url(recipe.source_url, recipe: recipe)
    else
      recipe.source_text
    end
  end
end
