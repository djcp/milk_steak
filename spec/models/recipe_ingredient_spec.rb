require 'spec_helper'

describe RecipeIngredient do
  it { should belong_to(:recipe) }
  it { should belong_to(:ingredient) }
  it { should validate_length_of(:quantity).is_at_most(10) }
  it { should validate_length_of(:unit).is_at_most(255) }
  it { should validate_length_of(:section).is_at_most(255) }
  it { should validate_length_of(:descriptor).is_at_most(255) }

  it "delegates name to ingredient" do
    recipe_ingredient = build(:recipe_ingredient)
    expect(recipe_ingredient.name).to eq recipe_ingredient.ingredient.name
  end

  describe "#ingredient_attributes=" do
    it "reuses an existing ingredient by name" do
      existing = create(:ingredient, name: 'flour')

      recipe_ingredient = build_stubbed(:recipe_ingredient)
      recipe_ingredient.ingredient_attributes = { 'name' => 'flour' }

      expect(recipe_ingredient.ingredient).to eq(existing)
    end

    it "matches case-insensitively" do
      existing = create(:ingredient, name: 'flour')

      recipe_ingredient = build_stubbed(:recipe_ingredient)
      recipe_ingredient.ingredient_attributes = { 'name' => 'Flour' }

      expect(recipe_ingredient.ingredient).to eq(existing)
    end

    it "creates a missing ingredient with a normalized name" do
      recipe_ingredient = build_stubbed(:recipe_ingredient)
      recipe_ingredient.ingredient_attributes = { 'name' => '  Whole Milk  ' }

      expect(recipe_ingredient.ingredient).to be_persisted
      expect(recipe_ingredient.ingredient.name).to eq('whole milk')
    end

    it "does not create a duplicate row when assigned again" do
      recipe_ingredient = build_stubbed(:recipe_ingredient)
      recipe_ingredient.ingredient_attributes = { 'name' => 'flour' }
      recipe_ingredient.ingredient_attributes = { 'name' => 'flour' }

      expect(Ingredient.where(name: 'flour').count).to eq(1)
    end

    it "ignores a forged id so a shared ingredient can never be renamed" do
      shared = create(:ingredient, name: 'flour')

      recipe_ingredient = build_stubbed(:recipe_ingredient)
      recipe_ingredient.ingredient_attributes = { 'id' => shared.id, 'name' => 'risen flour' }

      expect(recipe_ingredient.ingredient).to be_persisted
      expect(recipe_ingredient.ingredient.name).to eq('risen flour')
      expect(recipe_ingredient.ingredient.id).not_to eq(shared.id)
      expect(shared.reload.name).to eq('flour')
    end

    it "keeps the existing ingredient when the name is blank" do
      recipe_ingredient = create(:recipe_ingredient)
      original = recipe_ingredient.ingredient

      recipe_ingredient.ingredient_attributes = { 'name' => '' }

      expect(recipe_ingredient.ingredient).to eq(original)
    end

    it "builds a blank ingredient when there is none and the name is blank" do
      recipe_ingredient = build_stubbed(:recipe_ingredient)
      recipe_ingredient.ingredient = nil

      recipe_ingredient.ingredient_attributes = { 'name' => nil }

      expect(recipe_ingredient.ingredient).to be_a_new(Ingredient)
    end
  end

  context "position" do
    it "has a logical default position" do
      recipe_ingredient = create(:recipe_ingredient)
      expect(recipe_ingredient.position).to eq 1
    end

    it "can be reordered" do
      recipe = create(:recipe)
      first_recipe_ingredient = create(
        :recipe_ingredient,
        recipe: recipe
      )
      second_recipe_ingredient = create(
        :recipe_ingredient,
        recipe: recipe
      )
      expect(first_recipe_ingredient.position).to eq 1
      expect(second_recipe_ingredient.position).to eq 2

      first_recipe_ingredient.move_lower
      first_recipe_ingredient.save
      second_recipe_ingredient.reload

      expect(first_recipe_ingredient.position).to eq 2
      expect(second_recipe_ingredient.position).to eq 1
    end
  end
end
