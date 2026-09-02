module Admin
  class AiClassifierRunsController < BaseController
    before_action :find_run, only: %i[show rerun]

    after_action :verify_policy_scoped, only: :index

    def index
      authorize :ai_classifier_run, :index?
      base = scoped_runs

      per_page = params.fetch(:per_page, 10).to_i.clamp(1, 100)
      page     = (params[:page] || 1).to_i

      @recipe_ids        = paginated_recipe_ids(base, page, per_page)
      @runs_by_recipe_id = grouped_runs(base, @recipe_ids)
      @pagination        = WillPaginate::Collection.new(page, per_page, base.distinct.count(:recipe_id))

      assign_stats
      assign_filtered_recipe
    end

    def show
      authorize @run
    end

    def rerun
      authorize @run, :rerun?
      if @run.recipe.present?
        MagicRecipeJob.perform_later(@run.recipe.id)
        redirect_to admin_ai_classifier_run_path(@run), notice: 'Recipe re-enqueued for processing.'
      else
        redirect_to admin_ai_classifier_run_path(@run), alert: 'No associated recipe to rerun.'
      end
    end

    private

    def scoped_runs
      base = policy_scope(AiClassifierRun)
      base = base.by_success(params[:success]) if params[:success].present?
      base = base.for_recipe(params[:recipe_id]) if params[:recipe_id].present?
      base
    end

    def paginated_recipe_ids(base, page, per_page)
      query = base.group(:recipe_id).order(Arel.sql('MAX(started_at) DESC NULLS LAST'))
      query = query.limit(per_page).offset((page - 1) * per_page)
      query.pluck(:recipe_id)
    end

    def grouped_runs(base, recipe_ids)
      runs = base.where(recipe_id: recipe_ids).includes(:recipe).order(started_at: :desc)
      runs.group_by(&:recipe_id)
    end

    # One pass instead of four serial aggregates over the same scope. Not
    # cached: this page exists to observe recent runs, so stale counts would
    # defeat its purpose, and a single indexed aggregate is cheap.
    def assign_stats
      totals = policy_scope(AiClassifierRun).pick(Arel.sql(<<~SQL.squish)) || [0, 0, 0, nil]
        COUNT(*),
        COUNT(*) FILTER (WHERE success),
        COUNT(*) FILTER (WHERE NOT success),
        AVG(EXTRACT(EPOCH FROM (completed_at - started_at)) * 1000)
          FILTER (WHERE started_at IS NOT NULL AND completed_at IS NOT NULL)
      SQL

      @total_count, @success_count, @failure_count, average_duration = totals
      @avg_duration = average_duration&.round
    end

    def assign_filtered_recipe
      return if params[:recipe_id].blank?

      @filtered_recipe = policy_scope(Recipe).find(params[:recipe_id])
    end

    def find_run
      @run = policy_scope(AiClassifierRun).includes(:recipe).find(params[:id])
    end
  end
end
