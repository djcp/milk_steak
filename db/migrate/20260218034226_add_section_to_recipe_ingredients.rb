class AddSectionToRecipeIngredients < ActiveRecord::Migration[8.0]
  def change
    add_column :recipe_ingredients, :section, :string, limit: 255
  end
end
