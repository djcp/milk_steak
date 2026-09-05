require 'spec_helper'

# Guards the test harness itself.
#
# app/assets/javascripts/test_setup.js turns off jQuery animations and makes
# XHR synchronous so the js: true specs are deterministic. It was included
# without `defer: true` while jQuery above it was deferred, so it ran before
# jQuery existed, threw `$ is not defined`, and applied neither setting — for
# months, invisibly, while the Selenium specs flaked roughly one run in five.
#
# A silent no-op is exactly the kind of regression a suite should catch about
# itself, so assert the settings actually took rather than that the file exists.
feature 'Test harness', :js do
  scenario 'test_setup.js has run against a loaded jQuery' do
    visit '/'

    expect(page.evaluate_script('typeof jQuery')).to eq('function')
    expect(page.evaluate_script('jQuery.fx.off')).to be(true)
    expect(page.evaluate_script('jQuery.ajaxSettings.async')).to be(false)
  end
end
