class AddDescriptionToRecipes < ActiveRecord::Migration
  def change
    add_column :recipes, :description, :string, limit: 2.kilobytes, allow_nil: true
  end
end
