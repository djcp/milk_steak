require 'spec_helper'

describe Recipe do
  it { should have_many(:recipe_ingredients).dependent(:destroy) }
  it { should have_many(:ingredients).through(:recipe_ingredients) }
  it { should accept_nested_attributes_for(:recipe_ingredients) }
  it { should belong_to(:user) }

  it { should validate_presence_of(:name) }
  it { should ensure_length_of(:name).is_at_most(255) }

  it { should ensure_length_of(:serving_units).is_at_most(255) }

  it { should validate_numericality_of(:preparation_time) }
  it { should validate_numericality_of(:cooking_time) }
  it { should validate_numericality_of(:servings) }
end
