require 'spec_helper'

describe Autocompletes::CulturalInfluencesController do
  it_behaves_like 'an autocomplete controller', seed: lambda { |recipe, value|
    recipe.cultural_influence_list = value
    recipe.save!
  }
end
