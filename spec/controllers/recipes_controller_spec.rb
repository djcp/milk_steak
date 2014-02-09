require 'spec_helper'

describe RecipesController do
  context 'signed in user' do
    before do
      user = build(:user)
      request.env['warden'].stub(authenticate!: user)
      controller.stub(current_user: user)
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
    end
  end

  context 'guest user' do
    it 'is redirected to the sign-up form' do
      get :new

      expect(response).to redirect_to(new_user_session_path)
    end

    it 'has a logical message' do
      get :new

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end

def create_stubbed_recipe
  recipe = build_stubbed(:recipe)
  Recipe.stub(:create!).and_return(recipe)

  recipe
end

def user
  @user ||= build_stubbed(:user)
end
