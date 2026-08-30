class AddForeignKeyToAiClassifierRuns < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :ai_classifier_runs, :recipes, column: :recipe_id, on_delete: :nullify
  end
end
