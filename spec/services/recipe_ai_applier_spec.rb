require 'spec_helper'

describe RecipeAiApplier do
  let(:recipe) { create(:recipe, :draft, directions: nil) }

  let(:data) do
    {
      'name' => 'Chocolate Cake',
      'description' => 'A rich chocolate cake',
      'directions' => "1. Mix ingredients\n2. Bake at 350F",
      'preparation_time' => 15,
      'cooking_time' => 30,
      'servings' => 8,
      'serving_units' => 'slices',
      'ingredients' => [
        { 'quantity' => '2', 'unit' => 'cups', 'name' => 'flour', 'descriptor' => 'sifted', 'section' => 'Dry' },
        { 'quantity' => '1', 'unit' => 'cup', 'name' => 'sugar', 'section' => 'Dry' },
        { 'quantity' => '2', 'unit' => 'large', 'name' => 'eggs', 'section' => 'Wet' }
      ],
      'cooking_methods' => ['bake'],
      'cultural_influences' => ['american'],
      'courses' => ['dessert'],
      'dietary_restrictions' => ['vegetarian']
    }
  end

  describe '.apply' do
    it 'updates recipe attributes' do
      described_class.apply(recipe, data)

      recipe.reload
      expect(recipe.name).to eq('Chocolate Cake')
      expect(recipe.description).to eq('A rich chocolate cake')
      expect(recipe.directions).to include('Mix ingredients')
      expect(recipe.preparation_time).to eq(15)
      expect(recipe.cooking_time).to eq(30)
      expect(recipe.servings).to eq(8)
      expect(recipe.serving_units).to eq('slices')
    end

    it 'creates recipe ingredients' do
      described_class.apply(recipe, data)

      recipe.reload
      expect(recipe.recipe_ingredients.count).to eq(3)
      expect(recipe.ingredients.map(&:name)).to contain_exactly('flour', 'sugar', 'eggs')
    end

    it 'creates missing ingredients' do
      expect do
        described_class.apply(recipe, data)
      end.to change(Ingredient, :count).by(3)
    end

    it 'reuses existing ingredients' do
      Ingredient.create!(name: 'flour')

      expect do
        described_class.apply(recipe, data)
      end.to change(Ingredient, :count).by(2)
    end

    it 'assigns sections to recipe ingredients' do
      described_class.apply(recipe, data)

      recipe.reload
      sections = recipe.recipe_ingredients.order(:position).map(&:section)
      expect(sections).to eq(%w[Dry Dry Wet])
    end

    it 'assigns descriptors to recipe ingredients' do
      described_class.apply(recipe, data)

      recipe.reload
      flour_ri = recipe.recipe_ingredients.joins(:ingredient).find_by(ingredients: { name: 'flour' })
      sugar_ri = recipe.recipe_ingredients.joins(:ingredient).find_by(ingredients: { name: 'sugar' })
      expect(flour_ri.descriptor).to eq('sifted')
      expect(sugar_ri.descriptor).to be_nil
    end

    it 'sets tag lists' do
      described_class.apply(recipe, data)

      recipe.reload
      expect(recipe.cooking_method_list).to eq(['bake'])
      expect(recipe.cultural_influence_list).to eq(['american'])
      expect(recipe.course_list).to eq(['dessert'])
      expect(recipe.dietary_restriction_list).to eq(['vegetarian'])
    end

    it 'replaces existing ingredients on re-apply' do
      described_class.apply(recipe, data)

      new_data = data.merge('ingredients' => [
        { 'quantity' => '3', 'unit' => 'cups', 'name' => 'milk' }
      ])
      described_class.apply(recipe, new_data)

      recipe.reload
      expect(recipe.recipe_ingredients.count).to eq(1)
      expect(recipe.ingredients.map(&:name)).to eq(['milk'])
    end
  end

  describe 'AiClassifierRun recording' do
    it 'creates a run with service_class RecipeAiApplier' do
      expect { described_class.apply(recipe, data) }.to change(AiClassifierRun, :count).by(1)

      run = AiClassifierRun.includes(:recipe).last
      expect(run.service_class).to eq('RecipeAiApplier')
      expect(run.recipe).to eq(recipe)
      expect(run.adapter).to be_nil
      expect(run.ai_model).to be_nil
    end

    it 'records a successful run with completed_at' do
      described_class.apply(recipe, data)

      run = AiClassifierRun.last
      expect(run.success).to be true
      expect(run.started_at).not_to be_nil
      expect(run.completed_at).not_to be_nil
    end

    it 'stores data as JSON in user_prompt' do
      described_class.apply(recipe, data)

      run = AiClassifierRun.last
      expect(run.user_prompt).to eq(data.to_json)
    end

    context 'when save! raises' do
      it 'records a failed run and re-raises' do
        # Stub save! on this specific recipe instance (avoids any_instance interfering with
        # FactoryBot's lazy let evaluation which also calls save! on Recipe).
        allow(recipe).to receive(:save!).and_raise(RuntimeError, 'save failed')

        expect { described_class.apply(recipe, data) }.to raise_error(RuntimeError, 'save failed')

        run = AiClassifierRun.last
        expect(run.success).to be false
        expect(run.error_class).to eq('RuntimeError')
        expect(run.completed_at).not_to be_nil
      end
    end
  end
end
