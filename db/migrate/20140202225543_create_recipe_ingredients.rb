class CreateRecipeIngredients < ActiveRecord::Migration
  def change
    create_table :recipe_ingredients do |t|
      t.belongs_to :recipe, null: false
      t.belongs_to :ingredient, null: false
      t.integer :position
      t.decimal :quantity, precision: 5, scale: 3
      t.string :unit
      t.timestamps
    end

    add_index :recipe_ingredients, :position
    add_index :recipe_ingredients, :recipe_id
    add_index :recipe_ingredients, :ingredient_id
    add_index :recipe_ingredients, [:recipe_id, :ingredient_id], unique: true
  end
end
