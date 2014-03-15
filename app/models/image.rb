class Image < ActiveRecord::Base
  belongs_to :recipe
  validates :filepicker_url, presence: true, length: { maximum: 255 }
  validates :caption, length: { maximum: 1.kilobyte }
end
