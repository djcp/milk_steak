RubyLLM.configure do |config|
  config.anthropic_api_key = ENV.fetch('ANTHROPIC_API_KEY', nil)
  config.request_timeout   = 600
end
