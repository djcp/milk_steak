require 'spec_helper'

# config.exceptions_app routes status errors to ErrorsController, so these are
# what real 4xx/5xx responses render. Nothing covered them before.
describe 'Error pages', type: :request do
  ErrorsController::ERROR_PAGE_COPY.each do |status, (title, message)|
    it "renders the branded #{status} page with its own status code" do
      get "/#{status}"

      expect(response).to have_http_status(status)

      # Compare parsed text, not raw HTML: some copy contains an apostrophe
      # that is entity-escaped in the response body.
      text = response.parsed_body.text
      expect(text).to include(title)
      expect(text).to include(message)
    end
  end

  it 'renders without the nav or footer chrome' do
    get '/404'

    page = response.parsed_body
    expect(page.at_css('nav')).to be_nil
    expect(page.at_css('main')).to be_present
  end
end
