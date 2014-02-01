require 'spec_helper'

describe RecipesController do
  context '#new' do
    it "can render a form" do
      get :new
      expect(response).to be_successful
    end
  end

  context '#create' do

  end
end
