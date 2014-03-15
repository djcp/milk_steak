require 'spec_helper'

describe FeaturedImageChooser do
  it 'returns when there is a single featured image' do
    recipe = create(:full_recipe)
    image = create(:image, featured: true, recipe: recipe)

    expect(described_class.find(recipe)).to eq image
  end

  it 'returns the first image when there are multiple featured images' do
    recipe = create(:full_recipe)
    images = create_list(:image, 2, featured: true, recipe: recipe)

    expect(described_class.find(recipe)).to eq images.first
  end

  it 'returns nil when there are no images' do
    recipe = create(:full_recipe)

    expect(described_class.find(recipe)).to be_nil
  end

  it 'returns the first image when there are multiple non-featured images' do
    recipe = create(:full_recipe)
    images = create_list(:image, 2, featured: false, recipe: recipe)

    expect(described_class.find(recipe)).to eq images.first
  end
end
