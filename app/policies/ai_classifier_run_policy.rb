class AiClassifierRunPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def rerun?
    admin?
  end

  def create?
    false
  end

  def update?
    false
  end

  def destroy?
    false
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user&.admin?
      return scope.none if user.blank?

      scope.where(recipe_id: RecipePolicy::Scope.new(user, Recipe).resolve.select(:id))
    end
  end
end
