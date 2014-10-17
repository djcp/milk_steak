class RecipeOnPage
  include Capybara::DSL

  def title
    within '.recipe' do
      find('header h1').text
    end
  end

  def has_ingredient_fields_numbering?(count)
    all('fieldset#ingredients div.ingredient').count == count
  end

  def click_to_add_more_ingredients
    within('#ingredients') do
      click_on 'More ingredients'
    end
  end

  def has_autocomplete_including?(term)
    find('.ui-autocomplete li', text: term)
  end

  def cooking_methods
    all('.cooking_methods span').map(&:text)
  end

  def fill_in_serving_units_with(term)
    fill_in('recipe_serving_units', with: term)
  end

  def cultural_influences
    all('.cultural_influences span').map(&:text)
  end

  def courses
    all('.courses span').map(&:text)
  end

  def dietary_restrictions
    all('.dietary_restrictions span').map(&:text)
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

  def fill_in_cooking_methods_with(stuff)
    fill_in "recipe_cooking_method_list", with: stuff
  end

  def fill_in_cultural_influences_with(stuff)
    fill_in "recipe_cultural_influence_list", with: stuff
  end

  def fill_in_courses_with(stuff)
    fill_in "recipe_course_list", with: stuff
  end

  def fill_in_dietary_restrictions_with(stuff)
    fill_in "recipe_dietary_restriction_list", with: stuff
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
