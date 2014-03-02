class Recipe < ActiveRecord::Base
  has_many :recipe_ingredients, dependent: :destroy, inverse_of: :recipe
  has_many :ingredients, through: :recipe_ingredients
  belongs_to :user

  acts_as_taggable_on :cooking_methods, :cultural_influences,
    :courses, :dietary_restrictions

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

  def self.unique_serving_units
    select('serving_units').uniq()
  end

  def self.fuzzy_autocomplete_for(context, query)
    ActsAsTaggableOn::Tagging.includes(:tag).where(
      context: context,
      taggable_type: 'Recipe'
    ).uniq('name').where(
      'name like ?', "%#{query}%"
    )
  end

end
