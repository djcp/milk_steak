require 'spec_helper'

feature 'Auth screens' do
  scenario 'sign-in page renders the branded form' do
    visit new_user_session_path

    expect(page).to have_css('h2', text: 'Log in')
    expect(page).to have_field('Email')
    expect(page).to have_field('Password')
    expect(page).to have_button('Log in')
  end

  scenario 'sign-in page shows account helper links' do
    visit new_user_session_path

    expect(page).to have_link('Sign up')
    expect(page).to have_link('Forgot your password?')
    expect(page).to have_link("Didn't receive confirmation instructions?")
  end

  scenario 'forgot password page' do
    visit new_user_password_path

    expect(page).to have_css('h2', text: 'Forgot your password?')
    expect(page).to have_button('Send me password reset instructions')
    expect(page).to have_link('Log in')
  end

  scenario 'change password page' do
    token = create(:user).send_reset_password_instructions

    visit edit_user_password_path(reset_password_token: token)

    expect(page).to have_css('h2', text: 'Change your password')
    expect(page).to have_field('New password')
    expect(page).to have_button('Change my password')
  end

  scenario 'resend confirmation page' do
    visit new_user_confirmation_path

    expect(page).to have_css('h2', text: 'Resend confirmation instructions')
    expect(page).to have_button('Resend confirmation instructions')
  end

  scenario 'edit account page shows update and cancellation controls' do
    user_logs_in

    visit edit_user_registration_path

    expect(page).to have_css('h2', text: 'Edit account')
    expect(page).to have_button('Update')
    expect(page).to have_button('Cancel my account')
  end
end
