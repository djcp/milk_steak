class ChangeRecipeIngredientQuantityToString < ActiveRecord::Migration
  def change
    change_column :recipe_ingredients, :quantity, :string, limit: 10
  end
end
