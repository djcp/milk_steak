class Recipe < ActiveRecord::Base
  has_many :recipe_ingredients, dependent: :destroy, inverse_of: :recipe
  has_many :ingredients, through: :recipe_ingredients
  belongs_to :user

  accepts_nested_attributes_for :recipe_ingredients,
    reject_if: ->(attr) { attr['unit'].blank? }

  validates :preparation_time, :cooking_time, :servings,
    numericality: true, allow_blank: true
  validates :name, presence: true,
    length: { maximum: 255 }
  validates :serving_units, length: { maximum: 255 }
  validates :directions, presence: true,
    length: { maximum: 8.kilobytes }

  delegate :email, to: :user, prefix: true
end
