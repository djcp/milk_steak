class RecipeOnPage
  include Capybara::DSL

  def title
    within '.recipe' do
      find('header h1').text
    end
  end

  def ingredient_names
    all('.recipe_ingredient .name').map(&:text)
  end

  def ingredient_quantities
    all('.recipe_ingredient .quantity').map(&:text)
  end

  def user
    find('.user').text
  end

  def directions
    find('.recipe .directions').text
  end

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

  def submit
    click_on 'Create Recipe'
  end
end
