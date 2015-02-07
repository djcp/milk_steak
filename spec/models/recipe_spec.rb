require 'spec_helper'

describe Recipe do
  it { should have_many(:images).dependent(:destroy) }
  it { should have_many(:recipe_ingredients).dependent(:destroy) }
  it { should have_many(:ingredients).through(:recipe_ingredients) }
  it { should accept_nested_attributes_for(:recipe_ingredients) }
  it { should belong_to(:user) }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_most(255) }

  it { should validate_length_of(:serving_units).is_at_most(255) }

  it { should validate_presence_of(:directions) }
  it { should validate_length_of(:directions).is_at_most(8.kilobytes) }

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
end
