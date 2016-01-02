require 'spec_helper'

describe MealPlansController do
  context 'signed in user' do
    before do
      sign_in_user build(:user)
    end

    context '#new' do
      it "can render a form" do
        get :new

        expect(response).to be_successful
      end

      it "instantiates a meal plan" do
        allow(MealPlan).to receive(:new)
        get :new

        expect(MealPlan).to have_received(:new)
      end
    end
  end

  context 'guest user' do
    context '#new'
    it 'is redirected to the sign-up form' do
      get :new

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
