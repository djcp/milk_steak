require 'spec_helper'

describe MagicRecipeJob do
  let(:recipe) { create(:recipe, :draft, :magic, directions: nil) }

  let(:ai_result) do
    {
      'name' => 'Chocolate Cake',
      'description' => 'A rich chocolate cake',
      'directions' => "1. Mix ingredients\n2. Bake at 350F",
      'preparation_time' => 15,
      'cooking_time' => 30,
      'servings' => 8,
      'serving_units' => 'slices',
      'ingredients' => [
        { 'quantity' => '2', 'unit' => 'cups', 'name' => 'flour', 'section' => 'Dry' },
        { 'quantity' => '1', 'unit' => 'cup', 'name' => 'sugar', 'section' => 'Dry' },
        { 'quantity' => '2', 'unit' => 'large', 'name' => 'eggs', 'section' => 'Wet' }
      ],
      'cooking_methods' => ['bake'],
      'cultural_influences' => ['american'],
      'courses' => ['dessert'],
      'dietary_restrictions' => ['vegetarian']
    }
  end

  before do
    allow(RecipeTextExtractor).to receive(:from_url).and_return('some recipe text')
    allow(RecipeAiExtractor).to receive(:extract).and_return(ai_result)
  end

  it 'transitions recipe through processing to review' do
    described_class.perform_now(recipe.id)

    recipe.reload
    expect(recipe.status).to eq('review')
    expect(recipe.name).to eq('Chocolate Cake')
    expect(recipe.directions).to be_present
  end

  it 'creates ingredients' do
    described_class.perform_now(recipe.id)

    recipe.reload
    ingredient_names = recipe.recipe_ingredients.includes(:ingredient).map(&:name)
    expect(ingredient_names).to contain_exactly('flour', 'sugar', 'eggs')
  end

  it 'sets tags' do
    described_class.perform_now(recipe.id)

    recipe.reload
    expect(recipe.cooking_method_list).to eq(['bake'])
    expect(recipe.course_list).to eq(['dessert'])
  end

  context 'with source_text instead of URL' do
    let(:recipe) { create(:recipe, :draft, source_text: 'Some text', directions: nil) }

    it 'uses source_text directly' do
      allow(RecipeAiExtractor).to receive(:extract).with('Some text').and_return(ai_result)

      described_class.perform_now(recipe.id)

      expect(RecipeTextExtractor).not_to have_received(:from_url)
      expect(RecipeAiExtractor).to have_received(:extract).with('Some text')
    end
  end

  context 'when an error occurs' do
    before do
      allow(RecipeAiExtractor).to receive(:extract).and_raise(StandardError, 'API error')
    end

    it 'sets ai_error and status to processing_failed' do
      described_class.perform_now(recipe.id)

      recipe.reload
      expect(recipe.status).to eq('processing_failed')
      expect(recipe.ai_error).to eq('API error')
    end
  end
end
