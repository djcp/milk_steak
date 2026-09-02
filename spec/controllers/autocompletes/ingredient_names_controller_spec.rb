require 'spec_helper'

describe Autocompletes::IngredientNamesController do
  it_behaves_like 'an autocomplete controller', seed: lambda { |recipe, value|
    create(:recipe_ingredient, recipe: recipe, ingredient: create(:ingredient, name: value))
  }
end
