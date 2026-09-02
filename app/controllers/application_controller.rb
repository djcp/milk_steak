class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include Pundit::Authorization

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from Pundit::NotAuthorizedError do |exception|
    if exception.query.to_s == 'show?'
      # Preserve the no-existence-oracle: an unauthorized show looks like a
      # missing record to everyone, guest or not.
      raise ActiveRecord::RecordNotFound
    elsif current_user.blank?
      redirect_to new_user_session_path
    else
      redirect_to root_path, alert: t('not_authorized')
    end
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
  end

  def require_logged_in_approved!
    return redirect_to new_user_session_path if current_user.blank?
    return if current_user.approved?

    sign_out current_user
    redirect_to new_user_session_path, alert: I18n.t('devise.failure.pending_approval')
  end

  # Returns a safe, lowercased search term for autocomplete endpoints, or nil.
  # Guards against nil and array params (e.g. ?q[]=a), which would otherwise
  # raise NoMethodError / SQL type errors and return 500s.
  def autocomplete_query
    q = params[:q]
    return nil unless q.is_a?(String)

    q.strip.presence
  end

  # Values are already bound parameters, so this is not an injection fix: it
  # stops a literal % or _ in the term acting as a wildcard, which would make a
  # one-character query match every row.
  def like_pattern(value)
    ActiveRecord::Base.sanitize_sql_like(value.to_s)
  end
end
