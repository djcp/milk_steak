class RecipesController < ApplicationController
  layout 'admin', only: %i[new create edit update]

  before_action :require_logged_in_approved!, only: %i[new create edit update]
  before_action :find_recipe, only: %i[show edit update]

  after_action :verify_authorized

  def index
    authorize :recipe, :index?
    @filter_set = FilterSet.new(params.fetch(:filter_set, {}))
    @recipes = Recipe.published.includes(images: { image_attachment: :blob }).recent.paginate(
      page: page_param,
      per_page: per_page_param
    )
    @recipes = @filter_set.apply_to(@recipes)
  end

  def new
    @recipe = Recipe.new
    authorize @recipe
    set_up_form_for(@recipe)
  end

  def update
    authorize @recipe
    begin
      @recipe.update!(permitted_attributes(@recipe))
      flash[:notice] = t('ui.recipes.updated')
      redirect_to recipe_path(@recipe)
    rescue ActiveRecord::RecordInvalid => e
      flash[:error] = "#{t('ui.recipes.invalid_creation')}"
      set_up_form_for(@recipe)
      render :edit
    end
  end

  def create
    @recipe = Recipe.new(user: current_user, status: 'published')
    authorize @recipe
    @recipe.assign_attributes(permitted_attributes(@recipe))
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
    authorize @recipe
  end

  def edit
    authorize @recipe
    set_up_form_for(@recipe)
  end

  private

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
    @recipe = Recipe.includes(:user, :recipe_ingredients, :ingredients,
      images: { image_attachment: :blob }).find(params[:id])
  end

  def page_param
    [1, params.fetch(:page, 1).to_i].max
  end

  def per_page_param
    params.fetch(:per_page, 12).to_i.clamp(1, 48)
  end
end
