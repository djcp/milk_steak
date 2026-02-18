class MagicRecipeJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(recipe_id)
    recipe = Recipe.find(recipe_id)
    recipe.strict_loading!(false)
    recipe.update!(status: 'processing', ai_error: nil)

    text = extract_text(recipe)
    data = RecipeAiExtractor.extract(text)
    RecipeAiApplier.apply(recipe, data)

    recipe.update!(status: 'review')
  rescue StandardError => e
    recipe&.update_columns(status: 'processing_failed', ai_error: e.message) # rubocop:disable Rails/SkipsModelValidations
    raise
  end

  private

  def extract_text(recipe)
    if recipe.source_url.present?
      RecipeTextExtractor.from_url(recipe.source_url)
    else
      recipe.source_text
    end
  end
end
