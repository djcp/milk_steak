module Admin
  class BaseController < ApplicationController
    layout 'admin'
    before_action :require_logged_in_approved!

    after_action :verify_authorized

    private

    def require_admin!
      authorize :site, :admin_area?
    end
  end
end
