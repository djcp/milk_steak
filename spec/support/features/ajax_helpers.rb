module Features
  module AjaxHelpers
    # Blocks until jQuery has no requests in flight.
    #
    # The filter form's autocompletes fire on keyup, so a `fill_in` leaves an
    # XHR outstanding. Dismissing the menu with Escape isn't enough on its own:
    # if the response lands afterwards jQuery UI reopens the menu, and a menu
    # open across a page navigation makes Selenium raise "Node with given id
    # does not belong to the document".
    def wait_for_ajax
      Timeout.timeout(Capybara.default_max_wait_time) do
        sleep 0.05 until finished_all_ajax_requests?
      end
    end

    def finished_all_ajax_requests?
      page.evaluate_script('typeof jQuery === "undefined" || jQuery.active').to_i.zero?
    end
  end
end

RSpec.configure do |config|
  config.include Features::AjaxHelpers, type: :feature
end
