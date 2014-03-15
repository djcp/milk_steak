class FeaturedImageChooser
  def self.find(recipe)
    images = recipe.images
    images.find{ |image| image.featured } || images.first
  end
end
