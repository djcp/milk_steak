class CreateIngredients < ActiveRecord::Migration
  def change
    create_table :ingredients do |t|
      t.string :name, limit: 255, null: false
      t.string :notes, limit: 1.kilobyte
      t.string :url, limit: 1.kilobyte
    end

    add_index :ingredients, :name
  end
end
