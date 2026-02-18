module Admin
  class MagicRecipesController < BaseController
    def new; end

    def create
      recipe = Recipe.new(
        name: magic_recipe_name,
        user: current_user,
        status: 'draft',
        source_url: params[:source_url].presence,
        source_text: params[:source_text].presence
      )

      if recipe.save
        MagicRecipeJob.perform_later(recipe.id)
        redirect_to recipe_path(recipe), notice: 'Magic recipe created. AI processing will begin shortly.'
      else
        flash.now[:alert] = recipe.errors.full_messages.to_sentence
        render :new
      end
    end

    private

    def magic_recipe_name
      if params[:source_url].present?
        URI.parse(params[:source_url]).host&.delete_prefix('www.') || 'Magic Recipe'
      else
        'Magic Recipe'
      end
    rescue URI::InvalidURIError
      'Magic Recipe'
    end
  end
end
