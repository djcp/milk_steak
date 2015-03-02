require 'spec_helper'

feature 'User manages recipes', js: true do
  before do
    page.driver.allow_url('filepicker.io')
    page.driver.allow_url('googleapis.com')
  end

  scenario 'can add arbitrary numbers of ingredients' do
    user_logs_in

    click_on 'New Recipe'

    recipe_on_page.click_to_add_more_ingredients
    recipe_on_page.click_to_add_more_ingredients
    recipe_on_page.click_to_add_more_ingredients

    expect(recipe_on_page).to have_ingredient_fields_numbering(8)
  end

  scenario 'can update a recipe' do
    user_logs_in

    click_on 'New Recipe'

    recipe_on_page.fill_in_main_form_with(
      'Name' => 'Test recipe',
      'Preparation Time' => '5',
      'Cooking Time' => '15',
      'Servings' => '1',
      'Serving Units' => 'servings'
    )
    recipe_on_page.fill_in_directions_with(
      'Do stuff *amazing stuff*'
    )
    recipe_on_page.submit

    visit '/'

    click_on 'Test recipe'

    click_on 'edit'

    recipe_on_page.fill_in_main_form_with(
      'Name' => 'Updated Test recipe'
    )
    recipe_on_page.submit

    expect(page).to have_css('em', text: 'amazing stuff')

    visit '/'

    expect(page).to have_content('Updated Test recipe')
  end

  scenario 'values autocomplete' do
    user_logs_in
    recipe = create(
      :recipe,
      serving_units: 'pieces', cooking_method_list: 'bake, broil, saute'
    )
    click_on 'New Recipe'

    recipe_on_page.fill_in_cooking_methods_with(
      'bro'
    )
    expect(recipe_on_page).to have_autocomplete_including('broil')

    recipe_on_page.fill_in_serving_units_with('pi')
    expect(recipe_on_page).to have_autocomplete_including('pieces')
  end

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
        { quantity: 2.5, unit: 'tbps', name: 'butter' },
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
    recipe_on_page.fill_in_dietary_restrictions_with('low salt')

    recipe_on_page.submit

    expect(recipe_on_page.title).to match /Milk Steak/
    expect(recipe_on_page.ingredient_names).to include('steak', 'milk')
    expect(recipe_on_page.ingredient_quantities).to match_array([
      '1', '8', '2.5', '1'
    ])
    expect(recipe_on_page.directions).to include('Season steak')
    expect(recipe_on_page.cooking_methods).to include('saute')
    expect(recipe_on_page.cultural_influences).to include('american')
    expect(recipe_on_page.courses).to include('dinner')
    expect(recipe_on_page.dietary_restrictions).to include('low salt')
    expect(recipe_on_page.user).to eq user.email
  end
end

def recipe_on_page
  @recipe_on_page = RecipeOnPage.new
end

def image_file(file_name)
  File.open("spec/support/files/#{file_name}.jpg")
end
