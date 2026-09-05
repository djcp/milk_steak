module Features
  # Deterministically shuts down every jQuery UI autocomplete on the page.
  #
  # This replaces an earlier `wait_for_ajax` helper that polled `jQuery.active`.
  # That could not work: jQuery UI waits `options.delay` (300ms by default)
  # *before* issuing the request, so a poll fired straight after a `fill_in`
  # observed zero in-flight requests and returned immediately, having waited for
  # nothing.
  #
  # Blur is the barrier the polling was reaching for. jQuery UI's own blur
  # handler does `clearTimeout(this.searching)` and then `close()`, so it cancels
  # a search that has not fired yet *and* dismisses a menu that is already open,
  # in one step. Combined with the synchronous XHR set in test_setup.js — which
  # means no response can still be in flight — there is nothing left to race the
  # navigation that follows.
  module AutocompleteHelpers
    AUTOCOMPLETE_FIELDS = '.autocomplete_single, .autocomplete_multiple'.freeze

    def dismiss_autocompletes
      return if page.driver.is_a?(Capybara::RackTest::Driver)

      page.execute_script(<<~JS)
        if (typeof jQuery !== 'undefined') {
          jQuery('#{AUTOCOMPLETE_FIELDS}').trigger('blur');
        }
      JS

      # assert_no_selector rather than an expect(...) matcher so the helper works
      # unchanged inside RecipeOnPage, which has Capybara::DSL but no RSpec.
      assert_no_selector('.ui-autocomplete li', visible: :visible)
    end
  end
end

RSpec.configure do |config|
  config.include Features::AutocompleteHelpers, type: :feature
end
