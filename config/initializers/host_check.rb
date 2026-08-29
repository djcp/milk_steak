# Fails the deploy (web boot and the `release` step, which runs db:migrate) if
# HOST is not set in production. HOST is required for generating correct
# absolute URLs (e.g. Devise mailer links) and for the Host header checks that
# protect against DNS-rebinding / Host-header poisoning.
if Rails.env.production? && ENV['HOST'].to_s.strip.blank?
  raise <<~MSG
    HOST environment variable must be set in production.
    Set it to the public hostname (e.g. HOST=recipes.example.com) before deploying.
  MSG
end
