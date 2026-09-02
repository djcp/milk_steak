require 'spec_helper'

describe Autocompletes::DietaryRestrictionsController do
  it_behaves_like 'an autocomplete controller', seed: lambda { |recipe, value|
    recipe.dietary_restriction_list = value
    recipe.save!
  }
end
