MilkSteak::Application.configure do
  config.filepicker_rails.api_key = ENV['FILEPICKER_API_KEY']
  config.filepicker_rails.secret_key = ENV['FILEPICKER_SECRET_KEY']
end
