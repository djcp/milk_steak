class AddAiRunTelemetryToAiClassifierRuns < ActiveRecord::Migration[8.1]
  def change
    change_table :ai_classifier_runs, bulk: true do |t|
      t.integer :input_tokens
      t.integer :output_tokens
      t.string  :request_id
    end

    add_index :ai_classifier_runs, :request_id
  end
end
