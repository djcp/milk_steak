module RecipeCommands
  class Reject
    def initialize(recipe)
      @recipe = recipe
    end

    def call
      @recipe.update!(status: 'rejected')
      Result.new(success: true, message: 'Recipe rejected.')
    end
  end
end
