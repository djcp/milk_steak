require 'spec_helper'

feature 'User manages recipes', js: true do
  scenario 'adds a recipe' do
    user = user_logs_in

    click_on 'New Recipe'

    recipe_on_page.fill_in_main_form_with(
      'Name' => 'Milk Steak',
      'Preparation Time' => '5',
      'Cooking Time' => '15',
      'Servings' => '1',
      'Serving Units' => 'servings'
    )

    recipe_on_page.fill_in_ingredients_with(
      [
        { quantity: 1, unit: 'lb', name: 'steak' },
        { quantity: 8, unit: 'oz', name: 'milk' },
        { quantity: 1, unit: 'tbps', name: 'butter' },
        { quantity: 1, unit: 'pinch', name: 'black pepper' }
      ]
    )

    recipe_on_page.fill_in_directions_with(
      'Season steak with salt and pepper
Saute steak until browned on both sides
Simmer steak in milk until done
Serve with raw jellybeans
'
    )

    recipe_on_page.fill_in_cooking_methods_with(
      'saute, simmer'
    )
    recipe_on_page.fill_in_cultural_influences_with(
      'American, Philadelphia'
    )
    recipe_on_page.fill_in_courses_with(
      'dinner'
    )
    recipe_on_page.fill_in_dietary_restrictions_with('')

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
  user = create(:user)
  visit new_user_session_path
  fill_in 'Email', with: user.email
  fill_in 'Password', with: user.password
  click_on 'Sign in'
end

def recipe_on_page
  @recipe_on_page = RecipeOnPage.new
end
