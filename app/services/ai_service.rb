module AiService
  private

  # Template method: wraps the AI pipeline step in an AiClassifierRun lifecycle.
  #
  # Subclasses provide hook methods to supply run-specific data:
  #   - classifier_run_attributes  → merged into AiClassifierRun.create!
  #   - success_attributes(result) → merged into run.update! on success
  #   - transform_result(result)   → converts the block's return value before returning
  #
  # The block should return the raw result (e.g. raw API response string).
  # Use transform_result to post-process it (e.g. JSON.parse) without losing the
  # raw value that gets stored on the run record.
  def with_classifier_run
    run = AiClassifierRun.create!(
      service_class: self.class.name,
      recipe: @recipe,
      started_at: Time.current,
      success: false,
      **classifier_run_attributes
    )

    begin
      raw_result = yield
      run.update!(success: true, completed_at: Time.current, **success_attributes(raw_result))
      transform_result(raw_result)
    rescue StandardError => e
      run.update!(success: false, error_class: e.class.name, error_message: e.message, completed_at: Time.current)
      raise
    end
  end

  def classifier_run_attributes = {}
  def success_attributes(_raw_result) = {}
  def transform_result(raw_result) = raw_result
end
