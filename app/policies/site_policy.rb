class SitePolicy < ApplicationPolicy
  def admin_area?
    admin?
  end

  def magic?
    admin?
  end
end
