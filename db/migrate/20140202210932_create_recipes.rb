class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.string :name, null: false
      t.integer :preparation_time
      t.integer :cooking_time
      t.integer :servings
      t.string :serving_units
      t.string :directions, limit: 8.kilobytes, null: false
      t.belongs_to :user
    end

    add_index :recipes, :user_id
  end
end
