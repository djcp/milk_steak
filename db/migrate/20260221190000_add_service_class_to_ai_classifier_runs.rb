class AddServiceClassToAiClassifierRuns < ActiveRecord::Migration[8.0]
  def up
    add_column :ai_classifier_runs, :service_class, :string
    change_column_null :ai_classifier_runs, :adapter, true
    change_column_null :ai_classifier_runs, :ai_model, true
    execute "UPDATE ai_classifier_runs SET service_class = 'RecipeAiExtractor'"
    change_column_null :ai_classifier_runs, :service_class, false
  end

  def down
    remove_column :ai_classifier_runs, :service_class
    change_column_null :ai_classifier_runs, :adapter, false
    change_column_null :ai_classifier_runs, :ai_model, false
  end
end
