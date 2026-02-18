require 'spec_helper'

describe Recipe do
  describe 'status validation' do
    it 'is valid with a valid status' do
      recipe = build(:recipe, status: 'published')
      expect(recipe).to be_valid
    end

    it 'is invalid with an invalid status' do
      recipe = build(:recipe, status: 'bogus')
      expect(recipe).not_to be_valid
      expect(recipe.errors[:status]).to be_present
    end

    Recipe::STATUSES.each do |status|
      it "accepts '#{status}' as a valid status" do
        attrs = { status: status }
        attrs[:directions] = 'Some directions' unless status.in?(%w[draft processing processing_failed])
        recipe = build(:recipe, **attrs)
        expect(recipe).to be_valid
      end
    end
  end

  describe 'directions validation' do
    it 'requires directions for published recipes' do
      recipe = build(:recipe, status: 'published', directions: nil)
      expect(recipe).not_to be_valid
      expect(recipe.errors[:directions]).to be_present
    end

    it 'skips directions validation for draft recipes' do
      recipe = build(:recipe, status: 'draft', directions: nil)
      expect(recipe).to be_valid
    end

    it 'skips directions validation for processing recipes' do
      recipe = build(:recipe, status: 'processing', directions: nil)
      expect(recipe).to be_valid
    end
  end

  describe '.published' do
    it 'returns only published recipes' do
      published = create(:recipe, status: 'published')
      create(:recipe, status: 'draft', directions: nil)

      expect(described_class.published).to eq [published]
    end
  end

  describe '.by_status' do
    it 'filters by status when present' do
      review = create(:recipe, status: 'review')
      create(:recipe, status: 'published')

      expect(described_class.by_status('review')).to eq [review]
    end

    it 'returns all when status is blank' do
      create(:recipe, status: 'review')
      create(:recipe, status: 'published')

      expect(described_class.by_status(nil).count).to eq 2
    end
  end

  describe '#pre_review?' do
    it 'returns true for draft' do
      expect(build(:recipe, status: 'draft').pre_review?).to be true
    end

    it 'returns true for processing' do
      expect(build(:recipe, status: 'processing').pre_review?).to be true
    end

    it 'returns true for processing_failed' do
      expect(build(:recipe, :processing_failed).pre_review?).to be true
    end

    it 'returns false for review' do
      expect(build(:recipe, status: 'review').pre_review?).to be false
    end
  end

  describe '#reprocessable?' do
    it 'returns true for processing_failed' do
      expect(build(:recipe, :processing_failed).reprocessable?).to be true
    end

    it 'returns false for draft' do
      expect(build(:recipe, :draft).reprocessable?).to be false
    end

    it 'returns false for published' do
      expect(build(:recipe, status: 'published').reprocessable?).to be false
    end
  end

  describe '#publishable?' do
    it 'returns true for review status' do
      expect(build(:recipe, status: 'review').publishable?).to be true
    end

    it 'returns false for published status' do
      expect(build(:recipe, status: 'published').publishable?).to be false
    end
  end

  describe '#magic?' do
    it 'returns true when source_url is present' do
      expect(build(:recipe, source_url: 'https://example.com').magic?).to be true
    end

    it 'returns true when source_text is present' do
      expect(build(:recipe, source_text: 'Some recipe text').magic?).to be true
    end

    it 'returns false when neither is present' do
      expect(build(:recipe).magic?).to be false
    end
  end
end
