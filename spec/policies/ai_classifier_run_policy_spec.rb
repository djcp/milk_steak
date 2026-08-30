require 'spec_helper'

describe AiClassifierRunPolicy do
  let(:guest) { nil }
  let(:user)  { build_stubbed(:user) }
  let(:admin) { build_stubbed(:user, :admin) }
  let(:run)   { build_stubbed(:ai_classifier_run) }

  describe 'guest' do
    subject(:policy) { described_class.new(guest, run) }

    it 'cannot view or rerun runs' do
      expect(policy.index?).to be false
      expect(policy.show?).to be false
      expect(policy.rerun?).to be false
    end
  end

  describe 'member' do
    subject(:policy) { described_class.new(user, run) }

    it 'can view runs read-only' do
      expect(policy.index?).to be true
      expect(policy.show?).to be true
    end

    it 'cannot rerun the pipeline' do
      expect(policy.rerun?).to be false
    end
  end

  describe 'admin' do
    subject(:policy) { described_class.new(admin, run) }

    it 'can view and rerun runs' do
      expect(policy.index?).to be true
      expect(policy.show?).to be true
      expect(policy.rerun?).to be true
    end
  end

  describe 'scope' do
    it 'limits members to runs of their own recipes' do
      user = create(:user)
      mine = create(:recipe, user: user)
      my_run = create(:ai_classifier_run, :with_recipe, recipe: mine)
      create(:ai_classifier_run, :with_recipe)

      expect(described_class::Scope.new(user, AiClassifierRun.all).resolve).to contain_exactly(my_run)
    end

    it 'shows everything to admins' do
      admin = create(:user, :admin)
      create(:ai_classifier_run, :with_recipe)

      expect(described_class::Scope.new(admin, AiClassifierRun.all).resolve.count)
        .to eq(AiClassifierRun.count)
    end
  end
end
