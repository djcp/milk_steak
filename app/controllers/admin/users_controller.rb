module Admin
  class UsersController < BaseController
    before_action :require_admin!

    def index
      authorize :user, :index?
      @pending_users  = User.where(approved: false, admin: false).order(:created_at)
      @approved_users = User.where(approved: true,  admin: false).order(:created_at)
    end

    def approve
      authorize :user, :approve?
      # Scoped to the same set #index lists, so an id outside it 404s rather
      # than producing a misleading "approved" flash and a pointless write.
      @user = User.where(approved: false, admin: false).find(params[:id])
      @user.update!(approved: true)
      redirect_to admin_users_path, notice: "#{@user.username} has been approved."
    end
  end
end
