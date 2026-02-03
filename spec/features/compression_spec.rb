require 'spec_helper'

feature 'Compression' do
  # Note: This test verifies that compression middleware is configured.
  # In Rails 8, Rack::Deflater handles this automatically.
  # Full compression testing would require a request spec with proper headers.
  scenario "compression middleware is configured" do
    # Verify that Rack::Deflater is in the middleware stack
    expect(Rails.application.config.middleware).to include(Rack::Deflater)
  end
end
