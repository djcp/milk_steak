require 'spec_helper'

feature 'Admin recipe management' do
  let(:admin) { create(:user, :admin) }

  before { log_in_as(admin) }

  scenario 'status bar includes a link to create a magic recipe' do
    visit admin_recipes_path
    expect(page).to have_link('New Magic Recipe', href: new_admin_magic_recipe_path)
  end

  scenario 'status filter links filter recipes by status' do
    published = create(:recipe, user: admin)
    review    = create(:recipe, :review, user: admin)

    visit admin_recipes_path
    click_link 'Published'

    expect(page).to have_text(published.name)
    expect(page).not_to have_text(review.name)
  end
end
