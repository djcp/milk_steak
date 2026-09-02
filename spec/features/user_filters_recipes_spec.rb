require 'spec_helper'

feature 'User filters recipes', js: true do
  include RecipeGenerator

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

    fill_in 'filter_set_cooking_methods', with: 'deep fried'
    # The <details> <summary> serves as the field's accessible label.
    expect(find('#filter_set_cooking_methods')['aria-labelledby']).to eq('filter_cooking_methods_summary')
    # Let the keyup-triggered autocomplete request finish before dismissing the
    # menu; otherwise a late response reopens it after the Escape.
    wait_for_ajax
    # Dismiss the jQuery UI autocomplete menu (Escape) before submitting.
    # An open menu can race the page navigation in Selenium and raise
    # "Node with given id does not belong to the document".
    find('#filter_set_cooking_methods').send_keys(:escape)
    expect(page).to have_no_css('.ui-autocomplete', visible: :visible)
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
