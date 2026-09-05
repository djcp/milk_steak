require 'spec_helper'

# The filter form, the active-filter chips and "Clear filters" are all
# server-rendered, so these run on the default rack_test driver. Only the two
# genuinely-JavaScript behaviours — the jQuery UI autocomplete menu and the
# chip's remove button — need a browser; they live in the js: true group at the
# bottom.
feature 'User filters recipes' do
  include RecipeGenerator

  before { create_recipes }

  scenario 'filters by recipe name' do
    visit '/'
    fill_in 'Name', with: 'Burrito'
    click_on 'Apply'

    expect(page).to have_content('Burritos')
    expect(page).to have_no_content('French fries')
  end

  scenario 'filters by author' do
    cook = create(:user, username: 'saltbae')
    create(:recipe, name: 'Seared ribeye', user: cook)

    visit '/'
    fill_in 'Author', with: 'saltba'
    click_on 'Apply'

    expect(page).to have_content('Seared ribeye')
    expect(page).to have_no_content('Burritos')
  end

  scenario 'filters by cooking method, shows the active filter, and clears it' do
    visit '/'

    fill_in 'filter_set_cooking_methods', with: 'deep fried'
    # The <details> <summary> serves as the field's accessible label.
    expect(find('#filter_set_cooking_methods')['aria-labelledby'])
      .to eq('filter_cooking_methods_summary')

    click_on 'Apply'

    expect(page).to have_content 'French fries'
    expect(page).to have_no_content 'Burritos'

    within('.active_filters') do
      expect(page).to have_content('Cooking methods')
      expect(page).to have_content('deep fried')
    end

    click_on 'Clear filters'

    expect(page).to have_content 'Burritos'
    expect(page).to have_content 'French fries'
  end

  feature 'with JavaScript', :js do
    scenario 'suggests existing cooking methods as you type' do
      visit '/'

      fill_in 'filter_set_cooking_methods', with: 'de'

      expect(page).to have_css('.ui-autocomplete li', text: 'deep fried')
    end

    scenario 'removing a filter chip re-runs the search without it' do
      visit '/?filter_set%5Bname%5D=Burrito'

      expect(page).to have_content('Burritos')
      expect(page).to have_no_content('French fries')

      # Located by class, not by its aria-label: Capybara only matches buttons on
      # aria-label when Capybara.enable_aria_label is on, and it is not.
      find('.active_filters .remove_filter').click

      expect(page).to have_content('French fries')
    end
  end
end
