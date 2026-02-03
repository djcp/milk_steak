require 'spec_helper'

describe Image do
  it { should belong_to(:recipe) }
  it { should validate_length_of(:caption).is_at_most(1.kilobyte) }

  describe 'ActiveStorage attachment' do
    let(:recipe) { create(:recipe) }

    it 'can have an attached image' do
      image = build(:image, recipe: recipe)
      expect(image.image).to be_attached
    end

    it 'is invalid without an attached image' do
      image = Image.new(recipe: recipe)
      expect(image).not_to be_valid
      expect(image.errors[:image]).to include("can't be blank")
    end
  end

  describe '#image_url' do
    let(:image) { create(:image) }

    it 'returns nil if no image is attached' do
      image = Image.new
      expect(image.image_url).to be_nil
    end

    it 'returns the image for :original variant' do
      expect(image.image_url(:original)).to be_present
    end
  end
end
