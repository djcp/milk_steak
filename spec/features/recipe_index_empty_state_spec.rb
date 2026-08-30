require 'spec_helper'

feature 'Recipe index empty state' do
  scenario 'guest sees an empty state when there are no recipes' do
    visit '/'

    expect(page).to have_content('No recipes yet')
    expect(page).to have_content('Log in to add the first recipe to the cookbook.')
    expect(page).to have_link('Log in')
  end

  scenario 'signed-in user sees a CTA to add the first recipe' do
    user_logs_in

    visit '/'

    expect(page).to have_content('No recipes yet')
    expect(page).to have_content('Be the first to add a recipe to the cookbook.')
    expect(page).to have_link('Add your first recipe')
  end

  scenario 'a filter matching nothing shows a clear-filters empty state' do
    user = user_logs_in
    create(:recipe, user: user, name: 'Clearable Ziti')

    visit root_path(filter_set: { name: 'nonexistent' })

    expect(page).to have_content('No recipes match your search')
    expect(page).to have_link('Clear all filters')

    click_on 'Clear all filters'

    expect(page).to have_content('Clearable Ziti')
    expect(page).not_to have_content('No recipes match your search')
  end
end
