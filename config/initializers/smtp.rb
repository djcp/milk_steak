if Rails.env.production?
  SMTP_SETTINGS = {
    address: ENV['SMTP_ADDRESS'], # example: 'smtp.sendgrid.net'
    authentication: :plain,
    domain: ENV['SMTP_DOMAIN'], # example: 'this-app.com'
    password: ENV['SMTP_PASSWORD'],
    port: '587',
    user_name: ENV['SMTP_USERNAME'],
    enable_starttls_auto: true
  }
end
