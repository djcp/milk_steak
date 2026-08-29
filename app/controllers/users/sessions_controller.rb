module Users
  class SessionsController < Devise::SessionsController
    # Throttle password guessing on the public sign-in form. Complements
    # Devise :lockable (which locks a single account after many failures).
    rate_limit to: 10, within: 3.minutes, only: :create, with: :rate_limited

    private

    def rate_limited
      redirect_to new_user_session_path, alert: I18n.t('devise.failure.too_many_requests')
    end
  end
end
