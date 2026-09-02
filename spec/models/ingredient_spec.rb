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

  describe '.resolve_by_name' do
    it 'returns the existing ingredient rather than creating a duplicate' do
      existing = create(:ingredient, name: 'flour')

      expect { expect(described_class.resolve_by_name('flour')).to eq(existing) }
        .not_to change(described_class, :count)
    end

    it 'matches case-insensitively and on surrounding whitespace' do
      existing = create(:ingredient, name: 'flour')

      expect(described_class.resolve_by_name('  FLOUR  ')).to eq(existing)
    end

    it 'creates the ingredient when it does not exist yet' do
      expect { described_class.resolve_by_name('Semolina') }
        .to change(described_class, :count).by(1)

      expect(described_class.last.name).to eq('semolina')
    end

    it 'recovers when a concurrent writer wins the insert race' do
      winner = create(:ingredient, name: 'saffron')
      allow(described_class).to receive(:find_or_create_by)
        .and_raise(ActiveRecord::RecordNotUnique.new('duplicate key'))

      expect(described_class.resolve_by_name('saffron')).to eq(winner)
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
