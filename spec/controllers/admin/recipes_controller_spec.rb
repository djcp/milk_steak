require 'spec_helper'

describe Admin::RecipesController do
  describe 'non-admin access' do
    context 'when guest' do
      it 'redirects to sign in' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when regular user' do
      let(:user) { create(:user) }

      before { sign_in_user user }

      it 'shows only their own recipes' do
        mine = create(:recipe, user: user)
        theirs = create(:recipe)

        get :index

        expect(response).to be_successful
        expect(assigns(:recipes)).to include(mine)
        expect(assigns(:recipes)).not_to include(theirs)
        expect(assigns(:status_counts)).to have_key('published')
      end

      it 'deletes one of their own recipes' do
        mine = create(:recipe, user: user)

        expect do
          delete :destroy, params: { id: mine.id }
        end.to change(Recipe, :count).by(-1)

        expect(response).to redirect_to(admin_recipes_path)
      end

      it 'cannot see or act on another user\'s recipe' do
        theirs = create(:recipe)

        expect { delete :destroy, params: { id: theirs.id } }
          .to raise_error(ActiveRecord::RecordNotFound)
        expect { patch :publish, params: { id: theirs.id } }
          .to raise_error(ActiveRecord::RecordNotFound)
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
        expect(response).to redirect_to(admin_recipes_path)
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
        expect(response).to redirect_to(admin_recipes_path)
      end
    end

    describe '#reprocess' do
      it 'enqueues MagicRecipeJob for a processing_failed recipe' do
        recipe = create(:recipe, :processing_failed, :magic)

        expect do
          patch :reprocess, params: { id: recipe.id }
        end.to have_enqueued_job(MagicRecipeJob).with(recipe.id)

        expect(response).to redirect_to(admin_recipes_path)
        expect(flash[:notice]).to eq('Recipe re-enqueued for processing.')
      end

      it 'rejects reprocess for non-reprocessable recipes' do
        recipe = create(:recipe, :draft)
        patch :reprocess, params: { id: recipe.id }

        expect(response).to redirect_to(admin_recipes_path)
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
