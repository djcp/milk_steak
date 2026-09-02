class Ingredient < ApplicationRecord
  has_many :recipe_ingredients, dependent: :destroy
  has_many :recipes, through: :recipe_ingredients
  validates :name, presence: true,
    length: { maximum: 255 },
    uniqueness: true
  validates :notes, :url, allow_blank: true,
    length: { maximum: 1.kilobyte }

  before_validation :normalize_name

  # Resolve an ingredient by its normalized name, creating it when absent.
  #
  # The uniqueness validation covers the common case, but two concurrent
  # writers can both pass validation and then race the INSERT; the loser hits
  # the unique index on lower(name). Recover by re-reading the winner's row.
  #
  # Deliberately non-raising: an invalid name surfaces as a validation error on
  # the parent recipe save, which the recipe form renders, rather than a 500.
  def self.resolve_by_name(name)
    normalized = name.to_s.strip.downcase
    find_or_create_by(name: normalized)
  rescue ActiveRecord::RecordNotUnique
    find_by!(name: normalized)
  end

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
