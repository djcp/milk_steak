module Admin
  # NOTE: this base deliberately does NOT enforce admin. `admin/recipes` and
  # `admin/ai_classifier_runs` are a shared shell -- members reach them and see
  # only their own records via policy_scope. Only `require_logged_in_approved!`
  # and the `admin_area?` policy check are inherited.
  #
  # A new controller here that should be admin-only must opt in explicitly with
  # `before_action :require_admin!`, the way MagicRecipesController and
  # UsersController do.
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
