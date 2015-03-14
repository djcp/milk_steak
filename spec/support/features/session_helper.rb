module Features
  module SessionHelpers
    def user_logs_in
      # TODO - create user in the main thread
      # This right here is why the build fails on integration specs sometimes
      # The user creation happens outside the main thread.
      create(:user).tap do |user|
        user.confirm!
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
