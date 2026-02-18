class Recipe < ApplicationRecord
  STATUSES = %w[draft processing processing_failed review published rejected].freeze

  has_many :images, dependent: :destroy, inverse_of: :recipe
  has_many :recipe_ingredients, dependent: :destroy, inverse_of: :recipe
  has_many :ingredients, through: :recipe_ingredients
  belongs_to :user

  def self.recent
    order(created_at: :desc)
  end

  scope :published, -> { where(status: 'published') }
  scope :by_status, ->(s) { where(status: s) if s.present? }

  acts_as_taggable_on :cooking_methods, :cultural_influences,
    :courses, :dietary_restrictions

  # acts_as_taggable_on internally lazy-loads tagging associations;
  # exempt them from strict loading since we don't control the gem's queries.
  %i[taggings base_tags
     cooking_method_taggings cooking_methods
     cultural_influence_taggings cultural_influences
     course_taggings courses
     dietary_restriction_taggings dietary_restrictions].each do |assoc|
    reflect_on_association(assoc)&.options&.merge!(strict_loading: false)
  end

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
    length: { maximum: 8.kilobytes },
    unless: :pre_review?
  validates :description, length: { maximum: 2.kilobytes }
  validates :status, inclusion: { in: STATUSES }
  validates :source_url, format: { with: /\Ahttps?:\/\/\S+\z/i, message: 'must be an HTTP(S) URL' },
                         allow_blank: true

  delegate :email, to: :user, prefix: true, allow_nil: true

  def name_for_url
    name.downcase.gsub(/[^a-z\d ]/i,'').gsub(' ','_')
  end

  def self.unique_serving_units
    published_or_draft.select(:serving_units).distinct
  end

  def self.fuzzy_autocomplete_for(context, query)
    ActsAsTaggableOn::Tagging.includes(:tag).where(
      context: context,
      taggable_type: 'Recipe',
      taggable_id: published_or_draft.select(:id)
    ).joins(:tag).where(
      'tags.name like ?', "%#{query}%"
    ).distinct
  end

  scope :published_or_draft, -> { where(status: %w[published draft]) }

  def featured_image?
    featured_image.present?
  end

  def featured_image
    FeaturedImageChooser.find(self)
  end

  def pre_review?
    status.in?(%w[draft processing processing_failed])
  end

  def reprocessable?
    status == 'processing_failed'
  end

  def publishable?
    status == 'review'
  end

  def magic?
    source_url.present? || source_text.present?
  end
end
