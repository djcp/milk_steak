class AddMagicRecipeFieldsToRecipes < ActiveRecord::Migration[8.0]
  def change
    add_column :recipes, :source_url, :string, limit: 2048
    add_column :recipes, :source_text, :text
    add_column :recipes, :ai_error, :text
  end
end
