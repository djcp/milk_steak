require 'spec_helper'

describe Admin::RecipesController do
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

      it 'filters by status' do
        create(:recipe, status: 'published')
        create(:recipe, status: 'review')

        get :index, params: { status: 'review' }
        expect(assigns(:recipes).map(&:status)).to all(eq('review'))
      end
    end

    describe '#publish' do
      it 'publishes a review recipe' do
        recipe = create(:recipe, status: 'review')
        patch :publish, params: { id: recipe.id }

        expect(recipe.reload.status).to eq('published')
        expect(response).to redirect_to(recipe_path(recipe))
      end

      it 'does not publish a draft recipe' do
        recipe = create(:recipe, :draft)
        patch :publish, params: { id: recipe.id }

        expect(recipe.reload.status).to eq('draft')
        expect(flash[:alert]).to be_present
      end
    end

    describe '#reject' do
      it 'rejects a recipe' do
        recipe = create(:recipe, status: 'review')
        patch :reject, params: { id: recipe.id }

        expect(recipe.reload.status).to eq('rejected')
        expect(response).to redirect_to(recipe_path(recipe))
      end
    end

    describe '#reprocess' do
      it 'enqueues MagicRecipeJob for a processing_failed recipe' do
        recipe = create(:recipe, :processing_failed, :magic)

        expect do
          patch :reprocess, params: { id: recipe.id }
        end.to have_enqueued_job(MagicRecipeJob).with(recipe.id)

        expect(response).to redirect_to(recipe_path(recipe))
        expect(flash[:notice]).to eq('Recipe re-enqueued for processing.')
      end

      it 'rejects reprocess for non-reprocessable recipes' do
        recipe = create(:recipe, :draft)
        patch :reprocess, params: { id: recipe.id }

        expect(response).to redirect_to(recipe_path(recipe))
        expect(flash[:alert]).to be_present
      end
    end

    describe '#destroy' do
      it 'deletes the recipe and redirects to index' do
        recipe = create(:recipe)

        expect do
          delete :destroy, params: { id: recipe.id }
        end.to change(Recipe, :count).by(-1)

        expect(response).to redirect_to(admin_recipes_path)
        expect(flash[:notice]).to eq('Recipe deleted.')
      end
    end
  end
end
