module Admin
  class UsersController < BaseController
    def index
      @pending_users  = User.where(approved: false, admin: false).order(:created_at)
      @approved_users = User.where(approved: true,  admin: false).order(:created_at)
    end

    def approve
      @user = User.find(params[:id])
      @user.update!(approved: true)
      redirect_to admin_users_path, notice: "#{@user.username} has been approved."
    end
  end
end
