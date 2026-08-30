require 'spec_helper'

describe Ingredient do
  it { should have_many(:recipe_ingredients).dependent(:destroy) }
  it { should have_many(:recipes).through(:recipe_ingredients) }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_most(255) }

  it { should validate_length_of(:notes).is_at_most(1.kilobyte) }
  it { should validate_length_of(:url).is_at_most(1.kilobyte) }

  describe 'name normalization' do
    it 'stores a lowercased, trimmed name' do
      ingredient = described_class.new(name: '  Tomato Puree  ')
      ingredient.valid?
      expect(ingredient.name).to eq('tomato puree')
    end
  end

  describe 'name uniqueness' do
    it 'rejects a duplicate name' do
      create(:ingredient, name: 'flour')
      ingredient = build(:ingredient, name: 'flour')

      expect(ingredient).not_to be_valid
      expect(ingredient.errors[:name]).to include('has already been taken')
    end
  end
end
