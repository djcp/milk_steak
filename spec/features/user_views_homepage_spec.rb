require 'spec_helper'

feature 'User views homepage', js: true do
  scenario 'sees a paginated list of recipes' do
    generate_recipes
    user_logs_in
    visit '/'

    sees_a_list_of_new_recipes

    can_select_next_page
  end
end

def can_select_next_page
end

def sees_a_list_of_new_recipes
  expect(page).to have_css('div.recipe', count: 2)
end

def generate_recipes
  create_list(:full_recipe, 2)
end
