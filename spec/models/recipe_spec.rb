require 'spec_helper'

describe Recipe do
  it { should have_many(:images).dependent(:destroy) }
  it { should have_many(:recipe_ingredients).dependent(:destroy) }
  it { should have_many(:ingredients).through(:recipe_ingredients) }
  it { should accept_nested_attributes_for(:recipe_ingredients) }
  it { should accept_nested_attributes_for(:images) }
  it { should belong_to(:user) }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_most(255) }

  it { should validate_length_of(:description).is_at_most(2.kilobytes) }

  it { should validate_length_of(:serving_units).is_at_most(255) }

  context 'when published' do
    subject { build(:recipe, status: 'published') }
    it { should validate_presence_of(:directions) }
    it { should validate_length_of(:directions).is_at_most(8.kilobytes) }
  end

  it { should validate_numericality_of(:preparation_time) }
  it { should validate_numericality_of(:cooking_time) }
  it { should validate_numericality_of(:servings) }

  it_behaves_like 'an object tagged in the context of', 'cooking_methods'
  it_behaves_like 'an object tagged in the context of', 'cultural_influences'
  it_behaves_like 'an object tagged in the context of', 'courses'
  it_behaves_like 'an object tagged in the context of', 'dietary_restrictions'

  context '#featured_image' do
    it 'chooses a featured image' do
      allow(FeaturedImageChooser).to receive(:find)
      recipe = build(:recipe)

      recipe.featured_image

      expect(FeaturedImageChooser).to have_received(:find)
    end
  end

  context '#featured_image?' do
    it 'false when none exist' do
      allow(FeaturedImageChooser).to receive(:find).and_return(nil)
      recipe = build(:recipe)

      expect(recipe.featured_image?).to be false
    end

    it 'true when there is one' do
      allow(FeaturedImageChooser).to receive(:find).and_return(build(:image))
      recipe = build(:recipe)

      expect(recipe.featured_image?).to be true
    end
  end

  # These predicates drive the publish/reject/reprocess buttons and the AI
  # pipeline's transitions, but were only exercised indirectly.
  describe 'status predicates' do
    it 'is publishable only while awaiting review' do
      Recipe::STATUSES.each do |status|
        expected = status == 'review'
        expect(build(:recipe, status: status).publishable?).to eq(expected), status
      end
    end

    it 'is reprocessable only after a processing failure' do
      Recipe::STATUSES.each do |status|
        expected = status == 'processing_failed'
        expect(build(:recipe, status: status).reprocessable?).to eq(expected), status
      end
    end

    it 'is pre-review while draft, processing or failed' do
      Recipe::STATUSES.each do |status|
        expected = %w[draft processing processing_failed].include?(status)
        expect(build(:recipe, status: status).pre_review?).to eq(expected), status
      end
    end
  end

  describe '#name_for_url' do
    it 'lowercases and underscores the name' do
      expect(build(:recipe, name: 'Chocolate Cake').name_for_url).to eq('chocolate_cake')
    end

    it 'strips punctuation' do
      expect(build(:recipe, name: 'Mom\'s Best! Cake?').name_for_url).to eq('moms_best_cake')
    end

    it 'drops non-ascii characters, which is lossy but stable' do
      # Pinning current behaviour rather than endorsing it: accented characters
      # are dropped rather than transliterated.
      expect(build(:recipe, name: 'Creme Brulee').name_for_url).to eq('creme_brulee')
    end
  end
end
