require 'spec_helper'

describe HomesController do
  context '#index' do
    it 'paginates recent recipes' do
      recent_recipes = double('Recent Recipes', paginate: [])
      allow(Recipe).to receive(:recent).and_return(recent_recipes)

      get :index

      expect(recent_recipes).to have_received(:paginate)
    end
  end
end
