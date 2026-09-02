require 'spec_helper'

describe Autocompletes::ServingUnitsController do
  it_behaves_like 'an autocomplete controller', seed: lambda { |recipe, value|
    recipe.update!(serving_units: value)
  }
end
