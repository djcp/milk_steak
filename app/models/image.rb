class Image < ActiveRecord::Base
  belongs_to :recipe
  validates :caption, length: { maximum: 1.kilobyte }
  has_attached_file :image,
    styles: {
      tiny: "32x32#",
      thumb: "187x187#",
      large: "800x600>"
    },
    convert_options: {
      tiny: "-quality 50 -strip",
      thumb: "-quality 75 -strip",
      large: "-quality 85 -strip",
    }

  validates_attachment :image,
    presence: true,
    content_type: { :content_type => /\Aimage\/.*\Z/ },
    file_name: { :matches => [/png\Z/i, /jpe?g\Z/i] }
end
