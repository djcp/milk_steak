require 'spec_helper'

describe FeaturedImageChooser do
  def create_recipe_with_images_preloaded(**image_attrs)
    recipe = create(:full_recipe)
    images = image_attrs.empty? ? [] : create_list(:image, image_attrs.delete(:count) || 1, recipe: recipe, **image_attrs)
    [Recipe.includes(:images).find(recipe.id), images]
  end

  it 'returns when there is a single featured image' do
    recipe, images = create_recipe_with_images_preloaded(featured: true)

    expect(described_class.find(recipe)).to eq images.first
  end

  it 'returns the first image when there are multiple featured images' do
    recipe, images = create_recipe_with_images_preloaded(count: 2, featured: true)

    expect(described_class.find(recipe)).to eq images.first
  end

  it 'returns nil when there are no images' do
    recipe, _ = create_recipe_with_images_preloaded

    expect(described_class.find(recipe)).to be_nil
  end

  it 'returns the first image when there are multiple non-featured images' do
    recipe, images = create_recipe_with_images_preloaded(count: 2, featured: false)

    expect(described_class.find(recipe)).to eq images.first
  end
end
