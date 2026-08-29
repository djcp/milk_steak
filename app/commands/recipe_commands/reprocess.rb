module RecipeCommands
  class Reprocess
    def initialize(recipe)
      @recipe = recipe
    end

    def call
      if @recipe.reprocessable?
        MagicRecipeJob.perform_later(@recipe.id)
        Result.new(success: true, message: 'Recipe re-enqueued for processing.')
      else
        Result.new(success: false, message: 'Recipe cannot be reprocessed from its current status.')
      end
    end
  end
end
