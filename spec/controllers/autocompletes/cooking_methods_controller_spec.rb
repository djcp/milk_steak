require 'spec_helper'

describe Autocompletes::CookingMethodsController do
  it_behaves_like 'an autocomplete controller', seed: lambda { |recipe, value|
    recipe.cooking_method_list = value
    recipe.save!
  }
end
