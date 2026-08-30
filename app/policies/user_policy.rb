class UserPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def approve?
    admin?
  end
end
