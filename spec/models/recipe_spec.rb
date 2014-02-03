require 'spec_helper'

describe Recipe do
  it { should have_many(:recipe_ingredients) }
  it { should have_many(:ingredients).through(:recipe_ingredients) }
  it { should accept_nested_attributes_for(:ingredients) }
  it { should belong_to(:user) }
end
