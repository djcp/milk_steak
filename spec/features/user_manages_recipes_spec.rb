require 'spec_helper'

feature 'User manages recipes' do
  scenario 'adds a recipe' do
    user = user_logs_in

    visit new_recipe_path

    recipe_on_page.fill_in_form_with(
      name: 'Milk Steak',
      ingredients: '1 lb steak
8 oz milk
2 tsp salt
1 tablespoon butter
pinch black pepper',
      directions: 'Season steak with salt and pepper
Saute steak until browned on both sides
Simmer steak in milk until done
Serve with raw jellybeans
',
      cooking_methods: 'saute, simmer',
      cultural_influences: 'American, Philadelphia',
      courses: 'dinner',
      dietary_restrictions: ''
    )

    recipe_on_page.submit

    expect(recipe_on_page.title).to eq 'Milk Steak'
    expect(recipe_on_page.ingredient_names).to include('steak', 'milk')
    expect(recipe_on_page.ingredient_quantities).to include(
      '1 pound', '8 ounces'
    )
    expect(recipe_on_page.first_direction).to include('Season steak')
    expect(recipe_on_page.last_direction).to include('raw jellybeans')
    expect(recipe_on_page.cooking_methods).to include('saute')
    expect(recipe_on_page.cultural_influences).to include('American')
    expect(recipe_on_page.courses).to include('Dinner')
    expect(recipe_on_page.owner).to eq user.email
  end
end

def user_logs_in
end
