require 'spec_helper'

# Not js: true — pagination is entirely server-rendered, so the default
# rack_test driver exercises the same markup without a browser.
feature 'User views homepage' do
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
