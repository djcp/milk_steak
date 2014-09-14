require 'spec_helper'

describe 'app/views/recipes/_recipe.html.erb' do
  it 'displays an image preview' do
    recipe = build(:recipe)
    allow(recipe).to receive(:featured_image).and_return(build(:image, recipe: recipe))

    render partial: 'recipes/recipe', locals: {recipe: recipe}

    expect(recipe).to have_received(:featured_image).twice()
  end
end
