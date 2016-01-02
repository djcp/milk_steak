require 'spec_helper'

describe MealPlan do
  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_most(255) }

  it { should validate_presence_of(:description).is_at_most(8.kilobytes) }
end
