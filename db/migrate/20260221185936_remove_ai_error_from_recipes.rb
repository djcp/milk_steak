class RemoveAiErrorFromRecipes < ActiveRecord::Migration[8.0]
  def change
    remove_column :recipes, :ai_error, :text
  end
end
