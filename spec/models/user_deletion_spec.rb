require 'spec_helper'

# Devise's "Cancel my account" button (app/views/devise/registrations/edit.html.erb)
# promises it "permanently deletes your account, recipes, and images". Before the
# schema hardening migration, User had no `dependent:` and the recipes -> users FK
# defaulted to NO ACTION, so that button raised ActiveRecord::InvalidForeignKey for
# any user who owned a recipe. These specs pin the promised behaviour.
describe User do
  subject(:user) { create(:user) }

  describe 'account deletion' do
    it 'destroys the user along with their recipes, ingredients links and images' do
      recipe = create(:recipe, user: user)
      create(:recipe_ingredient, recipe: recipe)
      create(:image, recipe: recipe)

      expect { user.destroy! }
        .to change(described_class, :count).by(-1)
        .and change(Recipe, :count).by(-1)
        .and change(RecipeIngredient, :count).by(-1)
        .and change(Image, :count).by(-1)
    end

    it 'leaves the shared global ingredients alone' do
      recipe = create(:recipe, user: user)
      create(:recipe_ingredient, recipe: recipe)

      expect { user.destroy! }.not_to change(Ingredient, :count)
    end

    it 'does not touch another user\'s recipes' do
      other_recipe = create(:recipe)
      create(:recipe, user: user)

      user.destroy!

      expect(Recipe.exists?(other_recipe.id)).to be(true)
    end

    it 'preserves AI classifier runs, nullifying their recipe reference' do
      recipe = create(:recipe, user: user)
      run = create(:ai_classifier_run, recipe: recipe)

      expect { user.destroy! }.not_to change(AiClassifierRun, :count)

      run.reload
      expect(run.recipe_id).to be_nil
      expect(run.recipe_name).to eq('(recipe deleted)')
    end
  end
end
