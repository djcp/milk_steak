require 'spec_helper'

describe RecipeIngredient do
  it { should belong_to(:recipe) }
  it { should belong_to(:ingredient) }
  it { should validate_presence_of(:recipe) }
  it { should validate_presence_of(:ingredient) }
  it { should accept_nested_attributes_for(:ingredient) }
  it { should validate_numericality_of(:quantity) }
  it { should ensure_length_of(:unit).is_at_most(255) }

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
