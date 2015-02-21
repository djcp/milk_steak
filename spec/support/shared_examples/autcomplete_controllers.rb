shared_examples 'an autocomplete controller' do
  context '#index' do
    context 'non-authenticated user' do
      it 'is successful' do
        get :index, q: 'foo'

        expect(response).to be_successful
        expect(response.content_type).to eq 'application/json'
      end
    end

    context 'authenticated user' do
      it "gets json" do
        sign_in_user build(:user)

        get :index, q: 'foo'

        expect(response).to be_successful
        expect(response.content_type).to eq 'application/json'
      end
    end
  end
end
