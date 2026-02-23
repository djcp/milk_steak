require 'spec_helper'

describe Admin::AiClassifierRunsController do
  describe 'non-admin access' do
    context 'when guest' do
      it 'redirects from index' do
        get :index
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when regular user' do
      before { sign_in_user build(:user, admin: false) }

      it 'redirects from index' do
        get :index
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'admin access' do
    let(:admin) { build(:user, :admin) }

    before { sign_in_user admin }

    describe '#index' do
      it 'is successful' do
        get :index
        expect(response).to be_successful
      end

      it 'assigns recipe_ids grouped by most recent run' do
        recipe1 = create(:recipe)
        recipe2 = create(:recipe)
        create(:ai_classifier_run, :with_recipe, recipe: recipe1, started_at: 2.hours.ago)
        create(:ai_classifier_run, :with_recipe, recipe: recipe2, started_at: 1.hour.ago)

        get :index

        expect(assigns(:recipe_ids)).to eq([recipe2.id, recipe1.id])
      end

      it 'assigns runs grouped by recipe_id' do
        recipe = create(:recipe)
        run = create(:ai_classifier_run, :with_recipe, recipe: recipe)

        get :index

        expect(assigns(:runs_by_recipe_id)).to have_key(recipe.id)
        expect(assigns(:runs_by_recipe_id)[recipe.id]).to include(run)
      end

      it 'assigns pagination object' do
        get :index
        expect(assigns(:pagination)).to be_a(WillPaginate::Collection)
      end

      it 'filters by success param' do
        recipe1 = create(:recipe)
        recipe2 = create(:recipe)
        create(:ai_classifier_run, :with_recipe, recipe: recipe1, success: true)
        create(:ai_classifier_run, :with_recipe, :failed, recipe: recipe2)

        get :index, params: { success: 'true' }

        expect(assigns(:recipe_ids)).to include(recipe1.id)
        expect(assigns(:recipe_ids)).not_to include(recipe2.id)
      end

      it 'filters by recipe_id param' do
        recipe1 = create(:recipe)
        recipe2 = create(:recipe)
        create(:ai_classifier_run, :with_recipe, recipe: recipe1)
        create(:ai_classifier_run, :with_recipe, recipe: recipe2)

        get :index, params: { recipe_id: recipe1.id }

        expect(assigns(:recipe_ids)).to contain_exactly(recipe1.id)
        expect(assigns(:filtered_recipe)).to eq(recipe1)
      end

      it 'assigns stat counts' do
        create(:ai_classifier_run, success: true)
        create(:ai_classifier_run, :failed)

        get :index

        expect(assigns(:total_count)).to eq(2)
        expect(assigns(:success_count)).to eq(1)
        expect(assigns(:failure_count)).to eq(1)
      end
    end

    describe '#show' do
      it 'is successful and assigns the run' do
        run = create(:ai_classifier_run)
        get :show, params: { id: run.id }

        expect(response).to be_successful
        expect(assigns(:run)).to eq(run)
      end
    end

    describe '#rerun' do
      context 'when run has an associated recipe' do
        it 'enqueues MagicRecipeJob and redirects with notice' do
          recipe = create(:recipe, :processing_failed, :magic)
          run    = create(:ai_classifier_run, :with_recipe, recipe: recipe)

          expect do
            post :rerun, params: { id: run.id }
          end.to have_enqueued_job(MagicRecipeJob).with(recipe.id)

          expect(response).to redirect_to(admin_ai_classifier_run_path(run))
          expect(flash[:notice]).to eq('Recipe re-enqueued for processing.')
        end
      end

      context 'when run has no associated recipe' do
        it 'redirects with alert' do
          run = create(:ai_classifier_run)

          post :rerun, params: { id: run.id }

          expect(response).to redirect_to(admin_ai_classifier_run_path(run))
          expect(flash[:alert]).to eq('No associated recipe to rerun.')
        end
      end
    end
  end
end
