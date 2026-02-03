class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  def redirect_to_login
    redirect_to new_user_session_path and return
  end

  def forbidden
    render plain: 'forbidden', status: :forbidden
  end
end
