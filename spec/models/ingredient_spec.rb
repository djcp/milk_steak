require 'spec_helper'

describe Ingredient do
  it { should have_many(:recipe_ingredients).dependent(:destroy) }
  it { should have_many(:recipes).through(:recipe_ingredients) }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_most(255) }

  it { should validate_length_of(:notes).is_at_most(1.kilobyte) }
  it { should validate_length_of(:url).is_at_most(1.kilobyte) }
end
