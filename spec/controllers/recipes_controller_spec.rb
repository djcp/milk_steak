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

    context '#create' do
      context 'valid recipe' do
        it 'redirects to the new recipe' do
          recipe = create_stubbed_recipe

          post :create, {recipe: {name: 'foo'}}

          expect(response).to redirect_to(recipe_path(recipe))
        end

        it 'sends Recipe.create!' do
          create_stubbed_recipe

          post :create, {recipe: {name: 'foo'}}

          expect(Recipe).to have_received(:create!)
        end

        it 'sets a logical flash message' do
          create_stubbed_recipe

          post :create, {recipe: {name: 'foo'}}

          expect(flash[:message]).to eq I18n.t('created')
        end
      end

      context 'invalid recipe' do
        it 'sets a logical flash message' do
          post :create, {recipe: {name: 'foo'}}

          expect(flash[:error]).to include I18n.t('invalid_recipe_creation')
        end
        it 'does not error' do
          post :create, {recipe: {name: 'foo'}}

          expect(response).to be_successful
        end
      end
    end
  end

  context 'guest user' do
    context '#new' do
      it 'is redirected to the sign-up form' do
        get :new

        expect(response).to redirect_to(new_user_session_path)
      end

      it 'has a logical message' do
        post :create, {recipe: {name: 'foo'}}

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
  Recipe.stub(:create!).and_return(recipe)

  recipe
end
