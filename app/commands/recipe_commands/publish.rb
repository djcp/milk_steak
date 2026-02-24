module RecipeCommands
  class Publish
    def initialize(recipe)
      @recipe = recipe
    end

    def call
      if @recipe.publishable?
        @recipe.update!(status: 'published')
        Result.new(success: true, message: 'Recipe published.')
      else
        Result.new(success: false, message: 'Recipe cannot be published from its current status.')
      end
    end
  end
end
