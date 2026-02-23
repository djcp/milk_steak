class AiClassifierRun < ApplicationRecord
  ADAPTERS        = %w[anthropic].freeze
  SERVICE_CLASSES = %w[RecipeTextExtractor RecipeAiExtractor RecipeAiApplier].freeze

  belongs_to :recipe, optional: true

  validates :service_class, presence: true, inclusion: { in: SERVICE_CLASSES }
  validates :adapter,       inclusion: { in: ADAPTERS }, allow_nil: true
  validates :ai_model,      presence: true, if: -> { adapter.present? }
  validates :success,       inclusion: { in: [true, false] }

  scope :recent,      -> { order(created_at: :desc) }
  scope :successful,  -> { where(success: true) }
  scope :failed,      -> { where(success: false) }
  scope :by_success,  ->(val) { where(success: val) if val.in?(%w[true false]) }
  scope :for_recipe,  ->(id) { where(recipe_id: id) }

  def in_progress?
    completed_at.nil?
  end

  def duration_ms
    return nil unless started_at && completed_at

    ((completed_at - started_at) * 1000).round
  end

  def recipe_name
    recipe&.name || '(recipe deleted)'
  end
end
