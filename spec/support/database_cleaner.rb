RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  # append_after, not after. RSpec runs plain `after` hooks in *reverse*
  # registration order, and Capybara registers its `reset_sessions!` hook at
  # `require 'rspec/rails'` time — earlier than this file, which the
  # spec/support/**/*.rb glob loads afterwards. A plain `after` here therefore
  # ran *first*, truncating tables out from under a browser session that was
  # still open and could still have a request in flight. `append_after` runs
  # last, after the session is closed.
  config.append_after(:each) do
    # Capybara's own `after` hook (registered earlier, so it runs before this
    # one) calls reset_sessions!, which drains the Puma server's pending
    # requests. That is not quite airtight: a request the browser had already
    # put on the wire can land just after the drain returns, and then TRUNCATE's
    # AccessExclusiveLock deadlocks against the RowExclusiveLock that request
    # holds. Observed as:
    #
    #   PG::TRDeadlockDetected: Process A waits for AccessExclusiveLock on
    #   "users"; blocked by B. Process B waits for RowExclusiveLock on
    #   "recipes"; blocked by A.
    #
    # Postgres resolves the deadlock by killing one side, so retrying once —
    # after the loser's transaction is gone — succeeds. This is mitigation for a
    # residual race, not a root-cause fix; see docs/audits for the open item.
    attempts = 0
    begin
      DatabaseCleaner.clean
    rescue ActiveRecord::Deadlocked
      attempts += 1
      raise if attempts > 3

      sleep 0.1
      retry
    end
  end
end
