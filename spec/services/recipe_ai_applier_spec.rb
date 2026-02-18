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
        { 'quantity' => '2', 'unit' => 'cups', 'name' => 'flour' },
        { 'quantity' => '1', 'unit' => 'cup', 'name' => 'sugar' }
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
      expect(recipe.recipe_ingredients.count).to eq(2)
      expect(recipe.ingredients.map(&:name)).to contain_exactly('flour', 'sugar')
    end

    it 'creates missing ingredients' do
      expect do
        described_class.apply(recipe, data)
      end.to change(Ingredient, :count).by(2)
    end

    it 'reuses existing ingredients' do
      Ingredient.create!(name: 'flour')

      expect do
        described_class.apply(recipe, data)
      end.to change(Ingredient, :count).by(1)
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
end
