module RecipeGenerator
  # Two published recipes with distinguishable names and cooking methods, for
  # specs about browsing and filtering.
  #
  # This used to build them by driving the browser through two complete
  # recipe-form submissions — typing into eight autocomplete fields — purely to
  # get two rows into the database. That made every consumer a Selenium spec,
  # cost several seconds per example, and put the whole autocomplete race surface
  # in front of specs that were not testing autocompletes. The recipe form has
  # its own coverage in spec/features/user_manages_recipes_spec.rb; everything
  # else should just have the rows.
  def create_recipes
    [
      create(
        :recipe,
        name: 'Burritos',
        cooking_method_list: 'bake, broil, saute',
        directions: 'Do stuff *amazing stuff*'
      ),
      create(
        :recipe,
        name: 'French fries',
        cooking_method_list: 'deep fried',
        directions: 'Do stuff *amazing stuff*'
      )
    ]
  end

  def recipe_on_page
    @recipe_on_page = RecipeOnPage.new
  end
end
