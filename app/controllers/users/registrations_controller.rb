module Users
  class RegistrationsController < Devise::RegistrationsController
    # Throttle mass account creation from the public sign-up form.
    rate_limit to: 10, within: 10.minutes, only: :create, with: :rate_limited

    private

    def rate_limited
      redirect_to new_user_registration_path, alert: I18n.t('devise.failure.too_many_requests')
    end
  end
end
