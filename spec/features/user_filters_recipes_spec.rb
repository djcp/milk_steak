require 'spec_helper'

feature 'User filters recipes', js: true do
  before do
    page.driver.allow_url('filepicker.io')
    page.driver.allow_url('googleapis.com')

    create(
      :recipe,
      name: 'Burritos',
      serving_units: 'pieces',
      cooking_method_list: 'bake, broil, saute',
      cultural_influence_list: 'mexican',
      course_list: 'dinner',
      dietary_restriction_list: 'vegetarian'
    )
    create(
      :recipe,
      name: 'French fries',
      serving_units: 'pieces',
      cooking_method_list: 'deep fried',
      cultural_influence_list: 'american',
      course_list: 'breakfast',
      dietary_restriction_list: 'beefy'
    )
  end

  scenario 'filters by cooking method' do
    user_logs_in

    visit '/'

    fill_in 'Cooking methods', with: 'deep fried'
    click_on 'Apply'

    expect(page).to have_content 'French fries'
    expect(page).not_to have_content 'Burritos'

    click_on 'Clear filters'

    fill_in 'Name', with: 'burrit'
    click_on 'Apply'

    expect(page).to have_content 'Burritos'
    expect(page).not_to have_content 'French fries'
  end
end
