class Ingredient < ActiveRecord::Base
  has_many :recipe_ingredients, dependent: :destroy
  has_many :recipes, through: :recipe_ingredients
  validates :name, presence: true,
    length: { maximum: 255 }
  validates :notes, :url, allow_blank: true,
    length: { maximum: 1.kilobyte }
end
