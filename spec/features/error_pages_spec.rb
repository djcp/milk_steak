require 'spec_helper'

feature 'Error pages' do
  scenario 'renders a branded 404 page' do
    visit '/404'

    expect(page.status_code).to eq(404)
    expect(page).to have_content('Page not found')
    expect(page).to have_link('Back to the cookbook')
  end

  scenario 'renders a branded 422 page' do
    visit '/422'

    expect(page.status_code).to eq(422)
    expect(page).to have_content("That change didn't go through")
  end

  scenario 'renders a branded 500 page' do
    visit '/500'

    expect(page.status_code).to eq(500)
    expect(page).to have_content('Something went wrong')
  end
end
