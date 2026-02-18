require 'spec_helper'

feature 'User views homepage', js: true do
  include RecipeGenerator

  scenario 'sees a paginated list of recipes' do
    user_logs_in

    create_recipes
    visit '/'

    sees_a_list_of_recipes_numbering(2)

    visit '/?per_page=1'

    sees_a_list_of_recipes_numbering(1)

    expect(page).to have_link('Next')
  end
end

def sees_a_list_of_recipes_numbering(count)
  expect(page).to have_css('div.recipe', count: count)
end
