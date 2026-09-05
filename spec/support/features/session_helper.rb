module Features
  module SessionHelpers
    def log_in_as(user)
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      within('form#new_user') { click_on 'Log in' }

      # Barrier, not decoration. Clicking submit only *starts* the POST and its
      # redirect; without waiting for the page it lands on, the caller's next DOM
      # query races the navigation and chromedriver reports the node it was
      # inspecting as "Node with given id does not belong to the document".
      # That was the largest single source of flakiness in the js: true specs.
      # The failure message matters: when this barrier trips, the interesting
      # question is *why* the login did not complete (an unconfirmed account, a
      # pending-approval gate, a rate limit), and a bare "expected to find link"
      # answers none of it. Dumping what the page actually said turns a mystery
      # into a diagnosis.
      expect(page).to(
        have_link("#{user.email}, log out"),
        -> { "Login as #{user.email} did not complete. Page said:\n#{page.text[0, 800]}" }
      )

      user
    end

    # The user is created in the spec thread and js: true specs use the
    # truncation strategy (see spec/support/database_cleaner.rb), so the row is
    # committed and visible to the browser process.
    def user_logs_in
      log_in_as(create(:user).tap(&:confirm))
    end
  end
end
