class AddStatusToRecipes < ActiveRecord::Migration[8.0]
  def up
    add_column :recipes, :status, :string, null: false, default: 'draft'
    add_index :recipes, :status

    execute "UPDATE recipes SET status = 'published'"

    # Allow null directions for draft/processing recipes
    change_column_null :recipes, :directions, true
  end

  def down
    change_column_null :recipes, :directions, false, ''
    remove_column :recipes, :status
  end
end
