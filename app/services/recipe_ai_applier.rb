class RecipeAiApplier
  def self.apply(recipe, data)
    new(recipe, data).apply
  end

  def initialize(recipe, data)
    @recipe = recipe
    @data = data
  end

  def apply
    run = AiClassifierRun.create!(
      service_class: 'RecipeAiApplier',
      recipe: @recipe,
      user_prompt: @data.to_json,
      started_at: Time.current,
      success: false
    )

    begin
      @recipe.strict_loading!(false)
      @recipe.assign_attributes(
        name: @data['name'] || @recipe.name,
        description: @data['description'],
        directions: @data['directions'],
        preparation_time: @data['preparation_time'],
        cooking_time: @data['cooking_time'],
        servings: @data['servings'],
        serving_units: @data['serving_units']
      )

      apply_ingredients
      apply_tags

      @recipe.save!
      run.update!(success: true, completed_at: Time.current)
    rescue StandardError => e
      run.update!(success: false, error_class: e.class.name, error_message: e.message, completed_at: Time.current)
      raise
    end
  end

  private

  def apply_ingredients
    @recipe.recipe_ingredients.destroy_all

    Array(@data['ingredients']).each_with_index do |ing_data, index|
      ingredient = Ingredient.where(name: ing_data['name']).first_or_create!

      @recipe.recipe_ingredients.build(
        ingredient: ingredient,
        quantity: ing_data['quantity'],
        unit: ing_data['unit'],
        section: ing_data['section'],
        descriptor: ing_data['descriptor'],
        position: index + 1
      )
    end
  end

  def apply_tags
    @recipe.cooking_method_list = Array(@data['cooking_methods']).join(', ')
    @recipe.cultural_influence_list = Array(@data['cultural_influences']).join(', ')
    @recipe.course_list = Array(@data['courses']).join(', ')
    @recipe.dietary_restriction_list = Array(@data['dietary_restrictions']).join(', ')
  end
end
