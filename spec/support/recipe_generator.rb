module RecipeGenerator
  def create_recipes
    click_on 'New Recipe'
    recipe_on_page.fill_in_main_form_with(
      'Name' => 'Burritos'
    )
    recipe_on_page.fill_in_cooking_methods_with(
      'bake, broil, saute'
    )
    recipe_on_page.fill_in_directions_with(
      'Do stuff *amazing stuff*'
    )
    recipe_on_page.submit

    click_on 'New Recipe'
    recipe_on_page.fill_in_main_form_with(
      'Name' => 'French fries'
    )
    recipe_on_page.fill_in_cooking_methods_with(
      'deep fried'
    )

    recipe_on_page.fill_in_directions_with(
      'Do stuff *amazing stuff*'
    )
    recipe_on_page.submit
  end

  def recipe_on_page
    @recipe_on_page = RecipeOnPage.new
  end
end
