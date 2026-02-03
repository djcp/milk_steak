require 'spec_helper'

describe RecipesController do
  context 'signed in user' do
    before do
      sign_in_user build(:user)
    end

    context '#new' do
      it "can render a form" do
        get :new
        expect(response).to be_successful
      end
    end

    context '#update' do
      it 'is valid' do
        user = build(:user)
        allow(controller).to receive(:current_user).and_return(user)
        recipe = build_stubbed(:recipe, user: user)
        allow(Recipe).to receive(:find).and_return(recipe)
        get :edit, params: { id: recipe.id }

        expect(response).to be_successful
      end
    end

    context '#updated' do
      # it
    end

    context '#create' do
      context 'valid recipe' do
        it 'redirects to the new recipe' do
          recipe = create_stubbed_recipe

          post :create, params: { recipe: { name: 'foo' } }

          expect(response).to redirect_to(recipe_path(recipe))
        end

        it 'sends save!' do
          recipe = create_stubbed_recipe

          post :create, params: { recipe: { name: 'foo' } }

          expect(recipe).to have_received(:save!)
        end

        it 'sets a logical flash message' do
          create_stubbed_recipe

          post :create, params: { recipe: { name: 'foo' } }

          expect(flash[:notice]).to eq I18n.t('created')
        end
      end

      context 'invalid recipe' do
        it 'sets a logical flash message' do
          post :create, params: { recipe: { name: 'foo' } }

          expect(flash[:error]).to include I18n.t('ui.recipes.invalid_creation')
        end

        it 'does not error' do
          post :create, params: { recipe: { name: 'foo' } }

          expect(response).to be_successful
        end
      end
    end
  end

  context 'guest user' do
    context '#index' do
      it 'is successful' do
        get :index

        expect(response).to be_successful
      end
    end

    context '#show' do
      it 'is successful' do
        allow(Recipe).to receive(:find).and_return(build(:recipe))
        get :show, params: { id: 1 }

        expect(response).to be_successful
        expect(Recipe).to have_received(:find).with('1')
      end
    end

    context '#edit' do
      it 'is redirected to the sign-up form' do
        get :edit, params: { id: 1 }

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context '#update' do
      it 'is redirected to the sign-up form' do
        post :update, params: { id: 1 }

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context '#new' do
      it 'is redirected to the sign-up form' do
        get :new

        expect(response).to redirect_to(new_user_session_path)
      end

      it 'has a logical message' do
        post :create, params: { recipe: { name: 'foo' } }

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context '#create' do
      it 'cannot post to #create' do
        post :new

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end

def create_stubbed_recipe
  recipe = build_stubbed(:recipe)
  allow(Recipe).to receive(:new).and_return(recipe)
  allow(recipe).to receive(:save!)

  recipe
end
