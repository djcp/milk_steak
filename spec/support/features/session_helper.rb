module Features
  module SessionHelpers
    def log_in_as(user)
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      within('form#new_user') { click_on 'Log in' }
    end

    def user_logs_in
      # The user is created in the spec thread and js: true specs use the
      # truncation strategy (see spec/support/database_cleaner.rb), so the row
      # is committed and visible to the browser process. An earlier TODO here
      # blamed thread-visibility for intermittent failures; that premise no
      # longer holds under truncation.
      create(:user).tap do |user|
        user.confirm
        visit new_user_session_path
        fill_in 'Email', with: user.email
        fill_in 'Password', with: user.password
        within('form#new_user') do
          click_on 'Log in'
        end
      end
    end
  end
end
