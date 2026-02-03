class Recipe < ApplicationRecord
  has_many :images, dependent: :destroy, inverse_of: :recipe
  has_many :recipe_ingredients, dependent: :destroy, inverse_of: :recipe
  has_many :ingredients, through: :recipe_ingredients
  belongs_to :user

  def self.recent
    order('created_at desc')
  end

  acts_as_taggable_on :cooking_methods, :cultural_influences,
    :courses, :dietary_restrictions

  accepts_nested_attributes_for :recipe_ingredients,
    allow_destroy: true,
    reject_if: ->(attr) { attr['unit'].blank? && attr['quantity'].blank? }

  accepts_nested_attributes_for :images,
    allow_destroy: true,
    reject_if: ->(attr) { attr['id'].blank? && attr['image'].blank? }

  validates :preparation_time, :cooking_time, :servings,
    numericality: true, allow_blank: true
  validates :name, presence: true,
    length: { maximum: 255 }
  validates :serving_units, length: { maximum: 255 }
  validates :directions, presence: true,
    length: { maximum: 8.kilobytes }
  validates :description, length: { maximum: 2.kilobytes }

  delegate :email, to: :user, prefix: true, allow_nil: true

  def name_for_url
    name.downcase.gsub(/[^a-z\d ]/i,'').gsub(' ','_')
  end

  def self.unique_serving_units
    select(:serving_units).distinct
  end

  def self.fuzzy_autocomplete_for(context, query)
    ActsAsTaggableOn::Tagging.includes(:tag).where(
      context: context,
      taggable_type: 'Recipe'
    ).joins(:tag).where(
      'tags.name like ?', "%#{query}%"
    ).distinct
  end

  def featured_image?
    featured_image.present?
  end

  def featured_image
    FeaturedImageChooser.find(self)
  end
end
