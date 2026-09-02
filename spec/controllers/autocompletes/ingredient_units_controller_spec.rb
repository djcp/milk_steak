require 'spec_helper'

describe Autocompletes::IngredientUnitsController do
  it_behaves_like 'an autocomplete controller', seed: lambda { |recipe, value|
    create(:recipe_ingredient, recipe: recipe, unit: value)
  }
end
