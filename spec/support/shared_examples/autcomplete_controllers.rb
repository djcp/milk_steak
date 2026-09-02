# `seed` is required so that adding a new autocomplete endpoint without saying
# how to populate it is a loud failure rather than a silently missing draft
# disclosure test. It receives a recipe and a value, and must attach that value
# to the recipe in whatever way this endpoint queries.
shared_examples 'an autocomplete controller' do |seed:|
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

    context 'query handling' do
      it 'treats a LIKE wildcard as a literal, not a match-everything query' do
        instance_exec(create(:recipe, status: 'published'), 'realvalue', &seed)

        get :index, params: { q: '%' }

        # Bound parameters already prevent injection; the risk here is a bare
        # % returning the entire table as an autocomplete payload.
        expect(response.parsed_body).not_to include('realvalue')
      end

      it 'caps how many results it will return' do
        25.times do |i|
          instance_exec(create(:recipe, status: 'published'), "cappedvalue#{i}", &seed)
        end

        get :index, params: { q: 'cappedvalue' }

        expect(response.parsed_body.length).to be <= Recipe::AUTOCOMPLETE_LIMIT
      end
    end

    # Every autocomplete queries published recipes only. Without this, dropping
    # a `published` scope would leak unpublished content to anonymous callers
    # and no spec would fail.
    context 'draft disclosure' do
      it 'returns values from published recipes but never from drafts' do
        instance_exec(create(:recipe, :draft), 'secretdraftvalue', &seed)
        instance_exec(create(:recipe, status: 'published'), 'publishedvalue', &seed)

        get :index, params: { q: 'edvalue' }

        expect(response).to be_successful
        expect(response.parsed_body).to include('publishedvalue')
        expect(response.parsed_body).not_to include('secretdraftvalue')
      end
    end
  end
end
