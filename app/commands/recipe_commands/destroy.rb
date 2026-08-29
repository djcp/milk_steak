module RecipeCommands
  class Destroy
    def initialize(recipe)
      @recipe = recipe
    end

    def call
      @recipe.destroy!
      Result.new(success: true, message: 'Recipe deleted.')
    end
  end
end
