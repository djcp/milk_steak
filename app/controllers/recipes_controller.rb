class RecipesController < ApplicationController
  include Paginatable

  BLANK_INGREDIENT_ROWS = 5
  BLANK_IMAGE_ROWS = 4

  layout 'admin', only: %i[new create edit update]

  before_action :require_logged_in_approved!, only: %i[new create edit update]
  before_action :find_recipe, only: %i[show edit update]

  after_action :verify_authorized

  def index
    authorize :recipe, :index?
    @filter_set = FilterSet.new(params.fetch(:filter_set, {}))
    @recipes = Recipe.published.includes(
      :user, images: { image_attachment: { blob: :variant_records } }
    ).recent.paginate(
      page: page_param,
      per_page: per_page_param(default: 12, max: 48)
    )
    @recipes = @filter_set.apply_to(@recipes)
  end

  def show
    authorize @recipe
  end

  def new
    @recipe = Recipe.new
    authorize @recipe
    build_form_placeholders(@recipe)
  end

  def edit
    authorize @recipe
    build_form_placeholders(@recipe)
  end

  def create
    @recipe = Recipe.new(user: current_user, status: 'published')
    authorize @recipe
    @recipe.assign_attributes(permitted_attributes(@recipe))
    begin
      @recipe.save!
      flash[:notice] = t('created')
      redirect_to recipe_path(@recipe)
    rescue ActiveRecord::RecordInvalid
      flash[:error] = t('ui.recipes.invalid_creation').to_s
      build_form_placeholders(@recipe)
      render :new
    end
  end

  def update
    authorize @recipe
    begin
      @recipe.update!(permitted_attributes(@recipe))
      flash[:notice] = t('ui.recipes.updated')
      redirect_to recipe_path(@recipe)
    rescue ActiveRecord::RecordInvalid
      flash[:error] = t('ui.recipes.invalid_creation').to_s
      build_form_placeholders(@recipe)
      render :edit
    end
  end

  private

  # Tops the form up to a fixed number of blank rows instead of unconditionally
  # adding them. On a validation-failure re-render the recipe already carries
  # the unsaved rows built from params, so the old version stacked five *more*
  # blanks on top of them each time -- fail twice and the form grew to fifteen.
  #
  # Reads `target` rather than the association itself so this never triggers a
  # lazy load: on edit/update find_recipe has already preloaded it, and on new
  # or a failed create the in-memory rows are exactly what we want to count.
  def build_form_placeholders(recipe)
    blank_ingredients = BLANK_INGREDIENT_ROWS - recipe.recipe_ingredients.target.count(&:new_record?)
    blank_images = BLANK_IMAGE_ROWS - recipe.images.target.count(&:new_record?)

    [blank_ingredients, 0].max.times { recipe.recipe_ingredients.build(ingredient: Ingredient.new) }
    [blank_images, 0].max.times { recipe.images.build }
  end

  def find_recipe
    # The four tag contexts are preloaded because _show_content renders all of
    # them. Measured: this is query-neutral for a single recipe (four taggings
    # lookups either way), so it's for explicitness, not speed -- the audit's
    # claim of "4 extra round trips" only holds when rendering many recipes.
    # Worth keeping because these associations are exempt from strict loading
    # (see Recipe), so a future N+1 on them would be invisible to the suite.
    @recipe = Recipe.includes(:user, :recipe_ingredients, :ingredients,
                              :cooking_methods, :cultural_influences, :courses, :dietary_restrictions,
                              images: { image_attachment: { blob: :variant_records } }).find(params.expect(:id))
  end
end
