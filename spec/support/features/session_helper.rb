module Features
  module SessionHelpers
    def user_logs_in
      create(:user).tap do |user|
        visit new_user_session_path
        fill_in 'Email', with: user.email
        fill_in 'Password', with: user.password
        click_on 'Sign in'
      end
    end
  end
end
