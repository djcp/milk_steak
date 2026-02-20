class AddDescriptorToRecipeIngredients < ActiveRecord::Migration[8.0]
  def change
    add_column :recipe_ingredients, :descriptor, :string, limit: 255
  end
end
