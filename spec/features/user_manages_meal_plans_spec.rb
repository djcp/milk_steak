require 'spec_helper'

feature "User manages meal plans", js: true do
  before do
    page.driver.allow_url('googleapis.com')
  end

  scenario "can create one" do
    user_logs_in

    click_on 'New Meal Plan'

    fill_in "Name", with: "A meai plan"
    fill_in "Description", with: "An awesome description"

    click_on "Create"

    expect(page).to include('A meal plan')
    expect(page).to include('An awesome description')
  end

  scenario "can add a recipe"

  scenario "can delete a recipe"

  scenario "can reorder a recipe"

  scenario "can remove a meal plan"

  scenario "can get aggregate statistics about the recipes"

  scenario "can see a timeline of when recipes should be started"

end
