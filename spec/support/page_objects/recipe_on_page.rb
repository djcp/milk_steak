class RecipeOnPage
  include Capybara::DSL

  def fill_in_main_form_with(attributes = {})
    attributes.each do |k, v|
      field_id = "recipe_#{k.gsub(' ', '').underscore}"
      fill_in(field_id, with: v)
    end
  end

  def fill_in_ingredients_with(ingredients)
    ingredients.each_with_index do |ingredient, index|
      fill_in_ingredient(ingredient, index)
    end
  end

  def fill_in_ingredient(ingredient, index)
    fill_in "recipe_recipe_ingredients_attributes_#{index}_quantity",
      with: ingredient[:quantity]

    fill_in "recipe_recipe_ingredients_attributes_#{index}_unit",
      with: ingredient[:unit]

    fill_in "recipe_recipe_ingredients_attributes_#{index}_ingredient_attributes_name",
      with: ingredient[:name]
  end

  def fill_in_directions_with(directions)
    fill_in "recipe_directions", with: directions
  end
end
