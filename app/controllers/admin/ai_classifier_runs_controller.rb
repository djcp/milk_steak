module Admin
  class AiClassifierRunsController < BaseController
    before_action :find_run, only: %i[show rerun]

    def index
      base = AiClassifierRun.all
      base = base.by_success(params[:success]) if params[:success].present?
      base = base.for_recipe(params[:recipe_id]) if params[:recipe_id].present?

      per_page = 10
      page     = (params[:page] || 1).to_i
      total    = base.distinct.count(:recipe_id)

      @recipe_ids        = paginated_recipe_ids(base, page, per_page)
      @runs_by_recipe_id = grouped_runs(base, @recipe_ids)
      @pagination        = WillPaginate::Collection.new(page, per_page, total)

      assign_stats
      assign_filtered_recipe
    end

    def show; end

    def rerun
      if @run.recipe.present?
        MagicRecipeJob.perform_later(@run.recipe.id)
        redirect_to admin_ai_classifier_run_path(@run), notice: 'Recipe re-enqueued for processing.'
      else
        redirect_to admin_ai_classifier_run_path(@run), alert: 'No associated recipe to rerun.'
      end
    end

    private

    def paginated_recipe_ids(base, page, per_page)
      query = base.group(:recipe_id).order(Arel.sql('MAX(started_at) DESC NULLS LAST'))
      query = query.limit(per_page).offset((page - 1) * per_page)
      query.pluck(:recipe_id)
    end

    def grouped_runs(base, recipe_ids)
      runs = base.where(recipe_id: recipe_ids).includes(:recipe).order(started_at: :desc)
      runs.group_by(&:recipe_id)
    end

    def assign_stats
      @total_count   = AiClassifierRun.count
      @success_count = AiClassifierRun.successful.count
      @failure_count = AiClassifierRun.failed.count
      @avg_duration  = compute_avg_duration
    end

    def assign_filtered_recipe
      @filtered_recipe = Recipe.find(params[:recipe_id]) if params[:recipe_id].present?
    end

    def find_run
      @run = AiClassifierRun.includes(:recipe).find(params[:id])
    end

    def compute_avg_duration
      AiClassifierRun
        .where.not(started_at: nil).where.not(completed_at: nil)
        .average('EXTRACT(EPOCH FROM (completed_at - started_at)) * 1000')
        &.round
    end
  end
end
