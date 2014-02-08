class RecipeIngredient < ActiveRecord::Base
  belongs_to :recipe
  belongs_to :ingredient
  acts_as_list scope: :recipe

  validates :recipe, presence: true
  validates :ingredient, presence: true
  validates :quantity, numericality: true, allow_blank: true
  validates :unit, allow_blank: true,
    length: { maximum: 255 }

  accepts_nested_attributes_for :ingredient,
    reject_if: ->(attr) { attr['name'].blank? }

  delegate :name, to: :ingredient
end
