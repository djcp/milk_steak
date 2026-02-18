if Rails.env.production? && ENV.fetch('SMTP_ADDRESS', nil).present?
  SMTP_SETTINGS = {
    address: ENV.fetch('SMTP_ADDRESS', nil), # example: 'smtp.sendgrid.net'
    authentication: :plain,
    domain: ENV.fetch('SMTP_DOMAIN', nil), # example: 'this-app.com'
    password: ENV.fetch('SMTP_PASSWORD', nil),
    port: '587',
    user_name: ENV.fetch('SMTP_USERNAME', nil),
    enable_starttls_auto: true
  }.freeze
end
