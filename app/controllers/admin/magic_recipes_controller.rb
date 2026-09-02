module Admin
  class MagicRecipesController < BaseController
    layout 'application'

    before_action :require_admin!

    def new
      authorize :site, :magic?
    end

    def create
      authorize :site, :magic?
      recipe = Recipe.new(
        name: magic_recipe_name,
        user: current_user,
        status: 'draft',
        source_url: magic_recipe_params[:source_url].presence,
        source_text: magic_recipe_params[:source_text].presence
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

    # These are top-level params rather than a nested hash, so there is no
    # `require` to hang them off. Permitting them explicitly still gives the
    # boundary a name, so a later refactor can't splat unfiltered params into
    # Recipe.new and mass-assign status or user_id.
    def magic_recipe_params
      @magic_recipe_params ||= params.permit(:source_url, :source_text)
    end

    def magic_recipe_name
      if magic_recipe_params[:source_url].present?
        URI.parse(magic_recipe_params[:source_url]).host&.delete_prefix('www.') || 'Magic Recipe'
      else
        'Magic Recipe'
      end
    rescue URI::InvalidURIError
      'Magic Recipe'
    end
  end
end
