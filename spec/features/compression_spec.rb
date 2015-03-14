require 'spec_helper'

feature 'Compression' do
  scenario "a visitor has a browser that supports compression", :js do
    page.driver.allow_url('googleapis.com')

    ['deflate','gzip', 'deflate,gzip','gzip,deflate'].each do|compression_method|
      Capybara.current_session.driver.header('HTTP_ACCEPT_ENCODING', compression_method )
      visit '/'

      expect(page.response_headers.keys).to include('Content-Encoding')
    end
  end
end
