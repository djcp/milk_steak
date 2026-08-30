class Ingredient < ApplicationRecord
  has_many :recipe_ingredients, dependent: :destroy
  has_many :recipes, through: :recipe_ingredients
  validates :name, presence: true,
    length: { maximum: 255 },
    uniqueness: true
  validates :notes, :url, allow_blank: true,
    length: { maximum: 1.kilobyte }

  before_validation :normalize_name

  def self.unique_names
    joins(recipe_ingredients: :recipe)
      .where(recipes: { status: 'published' })
      .select(:name).distinct
  end

  private

  def normalize_name
    self.name = name.to_s.strip.downcase
  end
end
