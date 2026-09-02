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
    allow(RecipeTextExtractor).to receive(:from_url).with(anything, recipe: anything).and_return('some recipe text')
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
      allow(RecipeAiExtractor).to receive(:extract).with('Some text', recipe: recipe).and_return(ai_result)

      described_class.perform_now(recipe.id)

      expect(RecipeTextExtractor).not_to have_received(:from_url)
      expect(RecipeAiExtractor).to have_received(:extract).with('Some text', recipe: recipe)
    end
  end

  context 'when an error occurs' do
    before do
      allow(RecipeAiExtractor).to receive(:extract).and_raise(StandardError, 'API error')
    end

    it 'sets status to processing_failed' do
      described_class.perform_now(recipe.id)

      recipe.reload
      expect(recipe.status).to eq('processing_failed')
    end
  end

  describe 'failure handling' do
    # The `attempts: 3` count itself isn't asserted: ActiveJob closes over it
    # inside the retry_on block, so there's nothing to introspect, and driving
    # real retries would need the test adapter plus polynomially_longer waits.
    # What is worth pinning is the contract retrying depends on -- that the job
    # re-raises rather than swallowing, after recording the failure.
    it 're-raises after marking the recipe failed, so the job can retry' do
      recipe = create(:recipe, :magic)
      allow(RecipeTextExtractor).to receive(:from_url).and_raise(StandardError, 'boom')

      expect { described_class.new.perform(recipe.id) }.to raise_error(StandardError, 'boom')
      expect(recipe.reload.status).to eq('processing_failed')
    end

    it 'discards rather than retrying a failure that cannot succeed' do
      recipe = create(:recipe, :magic)
      allow(RecipeTextExtractor).to receive(:from_url)
        .and_raise(SafeUrlFetcher::BlockedAddressError, 'internal address')

      # perform_now runs the rescue handlers; a blocked URL will never
      # succeed, so burning three attempts on it is pure waste. The recipe is
      # still marked failed by the rescue inside #perform before re-raising.
      expect { described_class.perform_now(recipe.id) }.not_to raise_error
      expect(recipe.reload.status).to eq('processing_failed')
    end

    it 'still retries a transient upstream failure' do
      recipe = create(:recipe, :magic)
      allow(RecipeTextExtractor).to receive(:from_url)
        .and_raise(RecipeTextExtractor::FetchError, 'HTTP 503')

      # retry_on re-enqueues rather than raising, so this must not discard.
      expect { described_class.perform_now(recipe.id) }.not_to raise_error
      expect(recipe.reload.status).to eq('processing_failed')
    end

    it 'raises rather than swallowing a missing recipe' do
      expect { described_class.new.perform(-1) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
