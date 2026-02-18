class Image < ApplicationRecord
  ALLOWED_CONTENT_TYPES = %w[
    image/jpeg
    image/png
    image/webp
    image/avif
    image/heic
    image/heif
  ].freeze

  MAX_FILE_SIZE = 10.megabytes

  belongs_to :recipe
  has_one_attached :image

  validates :caption, length: { maximum: 1.kilobyte }
  validates :image, presence: true
  validates :image, content_type: { in: ALLOWED_CONTENT_TYPES,
                                    message: 'must be a JPEG, PNG, WebP, AVIF, or HEIC image' }
  validates :image, size: { less_than: MAX_FILE_SIZE,
                            message: 'must be less than 10 MB' }

  def image_url(variant = :original)
    return unless image.attached?

    case variant
    when :tiny
      image.variant(resize_to_fill: [32, 32], saver: { quality: 50, strip: true })
    when :thumb
      image.variant(resize_to_fill: [187, 187], saver: { quality: 75, strip: true })
    when :large
      image.variant(resize_to_limit: [800, 600], saver: { quality: 85, strip: true })
    else
      image
    end
  end
end
