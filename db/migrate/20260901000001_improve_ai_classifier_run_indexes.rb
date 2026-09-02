class ImproveAiClassifierRunIndexes < ActiveRecord::Migration[8.1]
  def change
    # The admin index groups by recipe_id and orders by MAX(started_at), and
    # then re-selects runs for the visible recipe ids ordered by started_at.
    # Both are served by this composite; neither was served by the plain
    # recipe_id index alone.
    add_index :ai_classifier_runs, %i[recipe_id started_at],
      order: { started_at: :desc },
      name: 'index_ai_classifier_runs_on_recipe_id_and_started_at'

    # `success` is a boolean, so a standalone index on it is near-useless: with
    # two distinct values the planner will nearly always prefer a sequential
    # scan. Replaced with a composite that also serves the ordering used by the
    # success/failure filter tabs.
    remove_index :ai_classifier_runs, :success, name: 'index_ai_classifier_runs_on_success'
    add_index :ai_classifier_runs, %i[success started_at],
      order: { started_at: :desc },
      name: 'index_ai_classifier_runs_on_success_and_started_at'
  end
end
