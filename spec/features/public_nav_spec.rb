require 'spec_helper'

feature 'Public nav' do
  scenario 'admin sees a Magic Recipe link in the header' do
    admin = create(:user, :admin)
    log_in_as(admin)

    visit root_path

    expect(page).to have_link('Magic Recipe', href: new_admin_magic_recipe_path)
  end

  scenario 'non-admin does not see a Magic Recipe link in the header' do
    user_logs_in

    visit root_path

    expect(page).to have_no_link('Magic Recipe')
  end
end
