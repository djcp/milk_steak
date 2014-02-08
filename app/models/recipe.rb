class Recipe < ActiveRecord::Base
  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients
  belongs_to :user

  accepts_nested_attributes_for :recipe_ingredients
  validates :preparation_time, :cooking_time, :servings,
    numericality: true, allow_blank: true
  validates :name, presence: true,
    length: { maximum: 255 }
  validates :serving_units, length: { maximum: 255 }
  validates :directions, presence: true,
    length: { maximum: 8.kilobytes }
end
