class RecipesController < ApplicationController
  before_action :redirect_to_login,
    if: -> {current_user.blank?},
    only: [:new, :update, :create, :edit]
  before_action :find_recipe, only: [:show, :edit, :update]
  before_action :can_update, only: [:edit, :update]

  def index
    @filter_set = FilterSet.new(params.fetch(:filter_set, {}))
    @recipes = Recipe.includes(:images).recent.paginate(
      page: page_param,
      per_page: per_page_param
    )
    @recipes = @filter_set.apply_to(@recipes)
  end

  def new
    @recipe = Recipe.new
    set_up_form_for(@recipe)
  end

  def update
    begin
      @recipe.update!(recipe_params)
      flash[:notice] = t('ui.recipes.updated')
      redirect_to recipe_path(@recipe)
    rescue ActiveRecord::RecordInvalid => e
      flash[:error] = "#{t('ui.recipes.invalid_creation')}"
      set_up_form_for(@recipe)
      render :edit
    end
  end

  def create
    @recipe = Recipe.new(recipe_params.merge(user: current_user))
    begin
      @recipe.save!
      flash[:notice] = t('created')
      redirect_to recipe_path(@recipe)
    rescue ActiveRecord::RecordInvalid => e
      flash[:error] = "#{t('ui.recipes.invalid_creation')}"
      set_up_form_for(@recipe)
      render :new
    end
  end

  def show
  end

  def edit
    set_up_form_for(@recipe)
  end

  private

  def recipe_params
    params.require(:recipe).permit(
      :name,
      :description,
      :preparation_time,
      :cooking_time,
      :services,
      :serving_units,
      :directions,
      :servings,
      :cooking_method_list,
      :cultural_influence_list,
      :course_list,
      :dietary_restriction_list,
      images_attributes: [
        :_destroy,
        :id,
        :caption,
        :featured,
        :image
      ],
      recipe_ingredients_attributes: [
        :_destroy,
        :id,
        :quantity,
        :unit,
        ingredient_attributes: [
          :id,
          :name
        ]
      ],
    )
  end

  def set_up_form_for(recipe)
    5.times do
      recipe.recipe_ingredients.build(
        ingredient: Ingredient.new
      )
    end
    4.times do
      recipe.images.build
    end
  end

  def find_recipe
    @recipe = Recipe.find(params[:id])
    ActiveRecord::Associations::Preloader.new(
      records: [@recipe],
      associations: [:user, :images, :recipe_ingredients, :ingredients]
    ).call
  end

  def can_update
    if @recipe.user != current_user
      redirect_to new_user_session_path and return
    end
  end

  def page_param
    params.fetch(:page, 1)
  end

  def per_page_param
    params.fetch(:per_page, 12)
  end
end
