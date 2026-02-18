require 'spec_helper'

describe Admin::MagicRecipesController do
  describe 'non-admin access' do
    context 'when guest' do
      it 'redirects from new' do
        get :new
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when regular user' do
      before { sign_in_user build(:user, admin: false) }

      it 'redirects from new' do
        get :new
        expect(response).to redirect_to(root_path)
      end

      it 'redirects from create' do
        post :create, params: { source_url: 'https://example.com' }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'admin access' do
    let(:admin) { create(:user, :admin) }

    before { sign_in_user admin }

    describe '#new' do
      it 'is successful' do
        get :new
        expect(response).to be_successful
      end
    end

    describe '#create' do
      it 'creates a draft recipe from URL and enqueues job' do
        expect do
          post :create, params: { source_url: 'https://example.com/recipe' }
        end.to change(Recipe, :count).by(1)
                                     .and have_enqueued_job(MagicRecipeJob)

        recipe = Recipe.last
        expect(recipe.status).to eq('draft')
        expect(recipe.source_url).to eq('https://example.com/recipe')
        expect(recipe.user_id).to eq(admin.id)
      end

      it 'creates a draft recipe from text and enqueues job' do
        expect do
          post :create, params: { source_text: 'Mix flour and water' }
        end.to change(Recipe, :count).by(1)
                                     .and have_enqueued_job(MagicRecipeJob)

        recipe = Recipe.last
        expect(recipe.source_text).to eq('Mix flour and water')
      end

      it 'redirects to recipe show' do
        post :create, params: { source_url: 'https://example.com/recipe' }
        expect(response).to redirect_to(recipe_path(Recipe.last))
      end
    end
  end
end
