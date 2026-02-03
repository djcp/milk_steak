# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [
  :password,
  :password_confirmation,
  :current_password,
  :token,
  :api_key,
  :secret,
  :confirmation_token,
  :reset_password_token,
  :unlock_token,
  :remember_token,
  :otp,
  :ssn,
  :credit_card,
  :cvv
]
