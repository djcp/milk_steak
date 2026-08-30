class RecipePolicy < ApplicationPolicy
  PERMITTED_ATTRIBUTES = %i[
    name description preparation_time cooking_time serving_units
    directions servings cooking_method_list cultural_influence_list
    course_list dietary_restriction_list
  ].freeze

  PERMITTED_IMAGES_ATTRIBUTES = %i[_destroy id caption featured image].freeze
  PERMITTED_RECIPE_INGREDIENT_ATTRIBUTES = %i[_destroy id quantity unit section descriptor].freeze
  PERMITTED_INGREDIENT_ATTRIBUTES = %i[name].freeze
  ADMIN_ATTRIBUTES = %i[source_url source_text status].freeze

  def index?
    true
  end

  def show?
    record.status == 'published' || owner? || admin?
  end

  def new?
    user.present?
  end

  def create?
    user.present?
  end

  def edit?
    return false if user.blank?

    owner? || admin?
  end

  def update?
    return false if user.blank?

    owner? || admin?
  end

  def destroy?
    return false if user.blank?

    owner? || admin?
  end

  def publish?
    admin?
  end

  def reject?
    admin?
  end

  def reprocess?
    admin?
  end

  def admin_fields?
    admin?
  end

  def permitted_attributes
    permitted = PERMITTED_ATTRIBUTES.dup
    permitted += ADMIN_ATTRIBUTES if admin?
    permitted + [
      {
        images_attributes: PERMITTED_IMAGES_ATTRIBUTES,
        recipe_ingredients_attributes: PERMITTED_RECIPE_INGREDIENT_ATTRIBUTES +
                                       [{ ingredient_attributes: PERMITTED_INGREDIENT_ATTRIBUTES }]
      }
    ]
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user&.admin?
      return scope.published if user.blank?

      scope.where(user: user)
    end
  end

  private

  def owner?
    record.user_id == user&.id
  end
end
