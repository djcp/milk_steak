require 'spec_helper'

describe Autocompletes::IngredientNamesController do
  it_behaves_like 'an autocomplete controller'

  context 'with non-published recipes' do
    it 'does not return ingredient names from non-published recipes' do
      draft = create(:recipe, :draft)
      create(:recipe_ingredient, recipe: draft, ingredient: create(:ingredient, name: 'secretdraftingredient'))

      published = create(:recipe)
      create(:recipe_ingredient, recipe: published, ingredient: create(:ingredient, name: 'publicingredient'))

      get :index, params: { q: 'ingredient' }

      expect(response).to be_successful
      expect(response.parsed_body).to include('publicingredient')
      expect(response.parsed_body).not_to include('secretdraftingredient')
    end
  end
end
