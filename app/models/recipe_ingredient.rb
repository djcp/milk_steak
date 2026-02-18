class RecipeIngredient < ApplicationRecord
  belongs_to :recipe
  belongs_to :ingredient
  acts_as_list scope: %i[recipe_id section]

  validates :recipe, presence: true
  validates :ingredient, presence: true
  validates :quantity,
    allow_blank: true,
    length: { maximum: 10 }
  validates :unit,
    allow_blank: true,
    length: { maximum: 255 }
  validates :section,
    allow_blank: true,
    length: { maximum: 255 }

  accepts_nested_attributes_for :ingredient,
    reject_if: ->(attr) { attr['name'].blank? }

  delegate :name, to: :ingredient

  def self.unique_units
    joins(:recipe)
      .where(recipes: { status: %w[published draft] })
      .select(:unit).distinct
  end
end
