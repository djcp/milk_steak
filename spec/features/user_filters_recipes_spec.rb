require 'spec_helper'

feature 'User filters recipes', js: true do
  include RecipeGenerator

  before do
    page.driver.allow_url('googleapis.com')
  end

  scenario 'filters by recipe owner' do
    user_logs_in

    create_recipes

    visit '/'
    fill_in 'Name', with: "Burrito"
    click_on 'Apply'

    expect(page).to have_content('Burrito')
    expect(page).not_to have_content('French fries')
  end

  scenario 'filters by cooking method' do
    user_logs_in
    create_recipes

    visit '/'

    fill_in 'Cooking methods', with: 'deep fried'
    click_on 'Apply'

    expect(page).to have_content 'French fries'
    expect(page).not_to have_content 'Burritos'

    within('.active_filters') do
      expect(page).to have_content('Cooking methods')
      expect(page).to have_content('deep fried')
    end

    click_on 'Clear filters'

    fill_in 'Name', with: 'burrit'
    click_on 'Apply'

    expect(page).to have_content 'Burritos'
    expect(page).not_to have_content 'French fries'
  end
end
