require 'capybara/selenium/driver'
require 'capybara/selenium/nodes/chrome_node'

# Safety net for a chromedriver quirk, not a substitute for the fixes around it.
#
# When a document is replaced while Capybara is filtering a result set, the nodes
# it collected belong to the old document. Selenium's own vocabulary for that is
# `StaleElementReferenceError`, which Capybara lists in `invalid_element_errors`
# and retries inside `Capybara::Node::Base#synchronize`. chromedriver instead
# reports it as a generic `UnknownError` carrying
# "Node with given id does not belong to the document" — which is not in that
# list, so it escapes the retry loop and fails the example outright.
#
# Translating just that one message back into the error Capybara already knows
# how to handle restores the retry. The match is on the message, so no other
# `UnknownError` is swallowed.
#
# Prepended to ChromeNode rather than its Node superclass so it covers both of
# ChromeNode#visible?'s branches: the CDP `is_element_displayed` call and the
# `super` fallback (the fallback is the one observed raising this).
module ToleratesDetachedNodes
  DETACHED_NODE_MESSAGE = 'does not belong to the document'.freeze

  def visible?
    super
  rescue ::Selenium::WebDriver::Error::UnknownError => e
    raise unless e.message.include?(DETACHED_NODE_MESSAGE)

    raise ::Selenium::WebDriver::Error::StaleElementReferenceError, e.message
  end
end

Capybara::Selenium::ChromeNode.prepend(ToleratesDetachedNodes)
