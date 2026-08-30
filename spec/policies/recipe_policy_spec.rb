require 'spec_helper'

describe RecipePolicy do
  def build_policy(role, recipe)
    described_class.new(role, recipe)
  end

  describe 'guest' do
    let(:published_recipe) { build_stubbed(:recipe, status: 'published') }
    let(:draft_recipe)     { build_stubbed(:recipe, status: 'draft') }

    it 'can browse the index' do
      expect(build_policy(nil, published_recipe).index?).to be true
    end

    it 'can view published recipes' do
      expect(build_policy(nil, published_recipe).show?).to be true
    end

    it 'cannot view unpublished recipes' do
      expect(build_policy(nil, draft_recipe).show?).to be false
    end

    it 'cannot create, edit, update, or delete recipes' do
      policy = build_policy(nil, published_recipe)
      %i[new? create? edit? update? destroy? publish? reject? reprocess?].each do |action|
        expect(policy.public_send(action)).to be false
      end
      expect(policy.admin_fields?).to be false
    end

    it 'does not permit admin-only strong params' do
      permitted = build_policy(nil, published_recipe).permitted_attributes
      expect(permitted).not_to include(:status)
      expect(permitted).not_to include(:source_url)
    end

    it 'always leaves ingredient ids out of strong params' do
      permitted = build_policy(nil, published_recipe).permitted_attributes
      nested = permitted.find { |attr| attr.is_a?(Hash) }
      ri_hash = nested[:recipe_ingredients_attributes].find { |attr| attr.is_a?(Hash) }
      expect(ri_hash[:ingredient_attributes]).to eq([:name])
    end

    describe 'scope' do
      it 'resolves to no recipes' do
        expect(described_class::Scope.new(nil, Recipe.all).resolve.count).to eq(0)
      end
    end
  end

  describe 'owner (non-admin)' do
    let(:draft_recipe) { build_stubbed(:recipe, user: owner, status: 'draft') }
    let(:owner)        { build_stubbed(:user) }

    it 'can view their own unpublished recipes' do
      expect(build_policy(owner, draft_recipe).show?).to be true
    end

    it 'can create, edit, update, and delete their own recipes' do
      policy = build_policy(owner, draft_recipe)
      %i[new? create? edit? update? destroy?].each do |action|
        expect(policy.public_send(action)).to be true
      end
    end

    it 'cannot publish, reject, or reprocess' do
      policy = build_policy(owner, draft_recipe)
      %i[publish? reject? reprocess?].each do |action|
        expect(policy.public_send(action)).to be false
      end
      expect(policy.admin_fields?).to be false
    end

    it 'does not permit admin-only strong params' do
      expect(build_policy(owner, draft_recipe).permitted_attributes).not_to include(:status)
    end

    describe 'scope' do
      it 'resolves to only their own recipes' do
        user = create(:user)
        mine = create(:recipe, user: user)
        create(:recipe)

        expect(described_class::Scope.new(user, Recipe.all).resolve).to contain_exactly(mine)
      end
    end
  end

  describe 'another user' do
    it 'cannot view, edit, update, delete, or moderate someone else\'s recipe' do
      owner = build_stubbed(:user)
      other = build_stubbed(:user)
      policy = build_policy(other, build_stubbed(:recipe, user: owner, status: 'review'))

      expect(policy.show?).to be false
      %i[edit? update? destroy? publish? reject? reprocess?].each do |action|
        expect(policy.public_send(action)).to be false
      end
    end
  end

  describe 'admin' do
    let(:review_recipe) { build_stubbed(:recipe, status: 'review') }
    let(:admin)         { build_stubbed(:user, :admin) }

    it 'can do everything' do
      policy = build_policy(admin, review_recipe)
      %i[index? show? new? create? edit? update? destroy? publish? reject? reprocess? admin_fields?].each do |action|
        expect(policy.public_send(action)).to be true
      end
    end

    it 'permits admin-only strong params' do
      expect(build_policy(admin, review_recipe).permitted_attributes).to include(:status, :source_url, :source_text)
    end

    it 'still never permits an ingredient id' do
      permitted = build_policy(admin, review_recipe).permitted_attributes
      nested = permitted.find { |attr| attr.is_a?(Hash) }
      ri_hash = nested[:recipe_ingredients_attributes].find { |attr| attr.is_a?(Hash) }
      expect(ri_hash[:ingredient_attributes]).to eq([:name])
    end

    describe 'scope' do
      it 'resolves to all recipes' do
        admin = create(:user, :admin)
        create(:recipe)

        expect(described_class::Scope.new(admin, Recipe.all).resolve).to eq(Recipe.all)
      end
    end
  end
end
