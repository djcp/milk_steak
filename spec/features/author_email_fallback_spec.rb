require 'spec_helper'

feature 'Author display' do
  scenario 'links the username to the author filter' do
    recipe = create(:recipe)

    visit recipe_path(recipe)

    expect(page).to have_css(
      ".user a[href='#{root_path(filter_set: { author: recipe.user_username })}']",
      text: recipe.user_username
    )
  end

  context 'when the author has no username (legacy account)' do
    let(:author) { create(:user, :no_username) }
    let!(:recipe) { create(:recipe, user: author) }

    scenario 'shows an armored email instead of the raw address' do
      visit recipe_path(recipe)

      expect(page).to have_css('.user .armored-email')
      expect(page.body).to include(author.email.reverse)
      expect(page.body).not_to include(author.email)
    end
  end
end
