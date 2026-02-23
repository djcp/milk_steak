class CreateAiClassifierRuns < ActiveRecord::Migration[8.0]
  def change
    create_table :ai_classifier_runs do |t|
      t.integer  :recipe_id
      t.string   :adapter,     null: false
      t.string   :ai_model,    null: false
      t.text     :system_prompt
      t.text     :user_prompt
      t.text     :raw_response
      t.boolean  :success,     null: false, default: false
      t.string   :error_class
      t.text     :error_message
      t.datetime :started_at
      t.datetime :completed_at
      t.timestamps
    end
    add_index :ai_classifier_runs, :recipe_id
    add_index :ai_classifier_runs, :success
    add_index :ai_classifier_runs, :created_at
  end
end
