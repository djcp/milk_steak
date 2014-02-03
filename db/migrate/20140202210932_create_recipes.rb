class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.string :name
      t.belongs_to :user
    end

    add_index :recipes, :user_id
  end
end
