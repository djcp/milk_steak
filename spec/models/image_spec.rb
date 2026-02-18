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

  describe 'content type validation' do
    let(:recipe) { create(:recipe) }

    it 'accepts JPEG images' do
      image = build(:image, recipe: recipe)
      expect(image).to be_valid
    end

    it 'accepts PNG images' do
      image = Image.new(recipe: recipe)
      image.image.attach(
        io: StringIO.new('fake png content'),
        filename: 'test.png',
        content_type: 'image/png'
      )
      expect(image).to be_valid
    end

    it 'accepts WebP images' do
      image = Image.new(recipe: recipe)
      image.image.attach(
        io: StringIO.new('fake webp content'),
        filename: 'test.webp',
        content_type: 'image/webp'
      )
      expect(image).to be_valid
    end

    it 'accepts AVIF images' do
      image = Image.new(recipe: recipe)
      image.image.attach(
        io: StringIO.new('fake avif content'),
        filename: 'test.avif',
        content_type: 'image/avif'
      )
      expect(image).to be_valid
    end

    it 'accepts HEIC images' do
      image = Image.new(recipe: recipe)
      image.image.attach(
        io: StringIO.new('fake heic content'),
        filename: 'test.heic',
        content_type: 'image/heic'
      )
      expect(image).to be_valid
    end

    it 'rejects non-image files' do
      image = Image.new(recipe: recipe)
      image.image.attach(
        io: StringIO.new('fake pdf content'),
        filename: 'test.pdf',
        content_type: 'application/pdf'
      )
      expect(image).not_to be_valid
      expect(image.errors[:image]).to include('must be a JPEG, PNG, WebP, AVIF, or HEIC image')
    end

    it 'rejects GIF images' do
      image = Image.new(recipe: recipe)
      image.image.attach(
        io: StringIO.new('fake gif content'),
        filename: 'test.gif',
        content_type: 'image/gif'
      )
      expect(image).not_to be_valid
      expect(image.errors[:image]).to include('must be a JPEG, PNG, WebP, AVIF, or HEIC image')
    end
  end

  describe 'file size validation' do
    let(:recipe) { create(:recipe) }

    it 'accepts files under 10 MB' do
      image = build(:image, recipe: recipe)
      expect(image).to be_valid
    end

    it 'rejects files over 10 MB' do
      image = Image.new(recipe: recipe)
      large_content = 'x' * (11 * 1024 * 1024) # 11 MB
      image.image.attach(
        io: StringIO.new(large_content),
        filename: 'large.jpg',
        content_type: 'image/jpeg'
      )
      expect(image).not_to be_valid
      expect(image.errors[:image]).to include('must be less than 10 MB')
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
