require 'spec_helper'

feature 'Guest browses recipes without logging in' do
  scenario 'sees published recipes but not drafts' do
    create(:recipe, name: 'Baked Ziti')
    create(:recipe, name: 'Secret Draft', status: 'draft')

    visit '/'

    expect(page).to have_content('Baked Ziti')
    expect(page).not_to have_content('Secret Draft')
  end

  scenario 'searches by name' do
    create(:recipe, name: 'Baked Ziti')
    create(:recipe, name: 'Burrito')

    visit '/'

    fill_in 'Name', with: 'burrito'
    click_on 'Apply'

    expect(page).to have_content('Burrito')
    expect(page).not_to have_content('Baked Ziti')
  end

  scenario 'filters by a cooking method tag' do
    fried = create(:recipe, name: 'Fried Chicken')
    fried.cooking_method_list.add('deep fried')
    fried.save!
    create(:recipe, name: 'Fresh Salad')

    visit '/'

    fill_in 'Cooking methods', with: 'deep fried'
    click_on 'Apply'

    expect(page).to have_content('Fried Chicken')
    expect(page).not_to have_content('Fresh Salad')
  end

  scenario 'opens a published recipe detail page' do
    create(:recipe, name: 'Baked Ziti')

    visit '/'

    click_on 'Baked Ziti'

    expect(page).to have_content('Baked Ziti')
    expect(page).to have_content('Do stuff')
  end
end
