class RemoveUniqueIndexFromRecipeIngredients < ActiveRecord::Migration[8.0]
  def change
    remove_index :recipe_ingredients, [:recipe_id, :ingredient_id], unique: true
    add_index :recipe_ingredients, [:recipe_id, :ingredient_id]
  end
end
