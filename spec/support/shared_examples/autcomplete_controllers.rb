shared_examples 'an autocomplete controller' do
  context '#index' do
    context 'non-authenticated user' do
      it 'is successful' do
        get :index, params: { q: 'foo' }

        expect(response).to be_successful
        expect(response.content_type).to include 'application/json'
      end

      it 'returns empty json when no query is given (does not enumerate)' do
        get :index

        expect(response).to be_successful
        expect(response.parsed_body).to eq([])
      end

      it 'does not error when q is an array' do
        get :index, params: { q: ['a'] }

        expect(response).to be_successful
        expect(response.parsed_body).to eq([])
      end
    end

    context 'authenticated user' do
      it "gets json" do
        sign_in_user build(:user)

        get :index, params: { q: 'foo' }

        expect(response).to be_successful
        expect(response.content_type).to include 'application/json'
      end
    end
  end
end
