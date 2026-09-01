require 'spec_helper'

feature 'Admin recipe management' do
  let(:admin) { create(:user, :admin) }

  before { log_in_as(admin) }

  scenario 'sidebar includes a link to create a magic recipe' do
    visit admin_recipes_path
    expect(page).to have_link('Magic Recipe', href: new_admin_magic_recipe_path)
  end

  scenario 'status filter links filter recipes by status' do
    published = create(:recipe, user: admin)
    review    = create(:recipe, :review, user: admin)

    visit admin_recipes_path
    click_link 'Published'

    expect(page).to have_text(published.name)
    expect(page).not_to have_text(review.name)
  end

  scenario 'shows an armored email for authors without a username' do
    author = create(:user, :no_username)
    create(:recipe, user: author)

    visit admin_recipes_path

    expect(page).to have_css('.armored-email')
    expect(page.body).to include(author.email.reverse)
    expect(page.body).not_to include(author.email)
  end
end
