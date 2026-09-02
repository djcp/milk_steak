class RecipeIngredient < ApplicationRecord
  belongs_to :recipe
  belongs_to :ingredient
  acts_as_list scope: %i[recipe_id section]

  validates :quantity,
    allow_blank: true,
    length: { maximum: 10 }
  validates :unit,
    allow_blank: true,
    length: { maximum: 255 }
  validates :section,
    allow_blank: true,
    length: { maximum: 255 }
  validates :descriptor,
    allow_blank: true,
    length: { maximum: 255 }

  delegate :name, to: :ingredient

  # Replaces `accepts_nested_attributes_for :ingredient`. Ingredient names are
  # normalized to lowercase and resolved create-or-match by name, so the recipe
  # form can never rename or duplicate the shared global Ingredient table --
  # for any role (admin included). An incoming `id` is deliberately ignored.
  def ingredient_attributes=(attrs)
    name = attrs['name'].to_s.strip.downcase

    if name.present?
      self.ingredient = Ingredient.resolve_by_name(name)
    else
      self.ingredient ||= Ingredient.new
    end
  end

  def self.unique_units
    joins(:recipe)
      .where(recipes: { status: 'published' })
      .select(:unit).distinct
  end
end
