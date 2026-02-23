class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
  end

  def redirect_to_login
    redirect_to new_user_session_path and return
  end

  def require_approved!
    return unless current_user
    return if current_user.approved?

    sign_out current_user
    redirect_to new_user_session_path, alert: I18n.t('devise.failure.pending_approval')
  end

  def forbidden
    render plain: 'forbidden', status: :forbidden
  end
end
