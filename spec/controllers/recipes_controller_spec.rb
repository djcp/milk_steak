require 'spec_helper'

describe RecipesController do
  context 'signed in user' do
    before do
      sign_in_user build(:user)
    end

    context '#index' do
      it 'shows the full published feed, including other users\' recipes' do
        other = create(:recipe)
        draft = create(:recipe, :draft)

        get :index

        expect(response).to be_successful
        expect(assigns(:recipes)).to include(other)
        expect(assigns(:recipes)).not_to include(draft)
      end
    end

    context '#new' do
      it "can render a form" do
        get :new
        expect(response).to be_successful
        expect(response).to render_template(layout: 'admin')
      end
    end

    context '#update' do
      it 'is valid' do
        user = build(:user)
        allow(controller).to receive(:current_user).and_return(user)
        recipe = build_stubbed(:recipe, user: user)
        scope = double(find: recipe)
        allow(Recipe).to receive(:includes).and_return(scope)
        get :edit, params: { id: recipe.id }

        expect(response).to be_successful
        expect(response).to render_template(layout: 'admin')
      end

      it "cannot edit another user's recipe" do
        user = build(:user)
        allow(controller).to receive(:current_user).and_return(user)
        recipe = build_stubbed(:recipe)
        scope = double(find: recipe)
        allow(Recipe).to receive(:includes).and_return(scope)

        get :edit, params: { id: recipe.id }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('Not authorized')
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

    context 'nested ingredient attributes' do
      before do
        allow(controller).to receive(:current_user).and_return(build(:user))
      end

      it 'never permits an ingredient id, for any role, so a shared ingredient cannot be renamed' do
        [build(:user), build(:user, :admin)].each do |user|
          expect(permitted_ingredient_attrs_for(user)).to eq([:name])
        end
      end

      it 'cannot rename a shared ingredient, even with a forged id' do
        shared = create(:ingredient, name: 'flour')
        allow(controller).to receive(:current_user).and_return(build(:user, :admin))

        post :create, params: {
          recipe: {
            name: 'foo',
            recipe_ingredients_attributes: [
              { quantity: '2', unit: 'cups', ingredient_attributes: { id: shared.id, name: 'Risen Flour' } }
            ]
          }
        }

        expect(shared.reload.name).to eq('flour')
        expect(Ingredient.where(name: 'risen flour').count).to eq(1)
      end
    end
  end

  context 'guest user' do
    context '#index' do
      it 'is successful' do
        get :index

        expect(response).to be_successful
      end

      it 'shows published recipes but not drafts' do
        draft = create(:recipe, :draft)
        published = create(:recipe)

        get :index

        expect(assigns(:recipes)).to include(published)
        expect(assigns(:recipes)).not_to include(draft)
      end
    end

    context '#show' do
      it 'is successful' do
        recipe = build_stubbed(:recipe, status: 'published')
        scope = double(find: recipe)
        allow(Recipe).to receive(:includes).and_return(scope)
        get :show, params: { id: recipe.id }

        expect(response).to be_successful
      end

      it 'treats a non-published recipe like a missing one (no existence oracle)' do
        recipe = build_stubbed(:recipe, :draft)
        scope = double(find: recipe)
        allow(Recipe).to receive(:includes).and_return(scope)

        # Same error as a nonexistent id; Rails maps RecordNotFound to a 404.
        expect { get :show, params: { id: recipe.id } }
          .to raise_error(ActiveRecord::RecordNotFound)
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

def permitted_ingredient_attrs_for(user)
  permitted = RecipePolicy.new(user, Recipe.new).permitted_attributes
  nested = permitted.find { |attr| attr.is_a?(Hash) }
  ri_hash = nested[:recipe_ingredients_attributes].find { |attr| attr.is_a?(Hash) }
  ri_hash[:ingredient_attributes]
end
