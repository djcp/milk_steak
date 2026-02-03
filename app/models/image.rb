class Image < ApplicationRecord
  belongs_to :recipe
  has_one_attached :image

  validates :caption, length: { maximum: 1.kilobyte }
  validates :image, presence: true

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
