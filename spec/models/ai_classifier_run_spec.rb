require 'spec_helper'

describe AiClassifierRun do
  describe 'associations' do
    it { should belong_to(:recipe).optional }
  end

  describe 'validations' do
    it { should validate_presence_of(:service_class) }
    it { should validate_inclusion_of(:service_class).in_array(AiClassifierRun::SERVICE_CLASSES) }
    it { should validate_inclusion_of(:adapter).in_array(AiClassifierRun::ADAPTERS).allow_nil }
    it { should validate_inclusion_of(:success).in_array([true, false]) }

    describe 'ai_model presence when adapter is set' do
      it 'is valid with no adapter and no ai_model' do
        run = build_stubbed(:ai_classifier_run, :text_extractor, ai_model: nil)
        expect(run).to be_valid
      end

      it 'requires ai_model when adapter is present' do
        run = build_stubbed(:ai_classifier_run, adapter: 'anthropic', ai_model: nil)
        expect(run).not_to be_valid
        expect(run.errors[:ai_model]).to be_present
      end
    end
  end

  describe '#in_progress?' do
    it 'returns true when completed_at is nil' do
      run = build_stubbed(:ai_classifier_run, completed_at: nil)
      expect(run.in_progress?).to be true
    end

    it 'returns false when completed_at is set' do
      run = build_stubbed(:ai_classifier_run, completed_at: Time.current)
      expect(run.in_progress?).to be false
    end
  end

  describe 'scopes' do
    let!(:successful_run) { create(:ai_classifier_run, success: true) }
    let!(:failed_run)     { create(:ai_classifier_run, :failed) }

    describe '.successful' do
      it 'returns only successful runs' do
        expect(described_class.successful).to contain_exactly(successful_run)
      end
    end

    describe '.failed' do
      it 'returns only failed runs' do
        expect(described_class.failed).to contain_exactly(failed_run)
      end
    end

    describe '.by_success' do
      it 'filters by true when passed "true"' do
        expect(described_class.by_success('true')).to contain_exactly(successful_run)
      end

      it 'filters by false when passed "false"' do
        expect(described_class.by_success('false')).to contain_exactly(failed_run)
      end

      it 'returns all when passed an invalid value' do
        result = described_class.by_success('invalid')
        expect(result).to include(successful_run, failed_run)
      end
    end

    describe '.recent' do
      it 'orders by created_at descending' do
        older = create(:ai_classifier_run, created_at: 1.hour.ago)
        newer = create(:ai_classifier_run, created_at: 1.minute.ago)
        scoped = described_class.recent.where(id: [older.id, newer.id])
        expect(scoped.first).to eq(newer)
        expect(scoped.last).to eq(older)
      end
    end

    describe '.for_recipe' do
      it 'returns runs for the given recipe_id' do
        recipe = create(:recipe)
        run    = create(:ai_classifier_run, :with_recipe, recipe: recipe)
        other  = create(:ai_classifier_run)

        expect(described_class.for_recipe(recipe.id)).to contain_exactly(run)
        expect(described_class.for_recipe(recipe.id)).not_to include(other)
      end
    end
  end

  describe '#duration_ms' do
    it 'returns nil when started_at is missing' do
      run = build_stubbed(:ai_classifier_run, started_at: nil, completed_at: Time.current)
      expect(run.duration_ms).to be_nil
    end

    it 'returns nil when completed_at is missing' do
      run = build_stubbed(:ai_classifier_run, started_at: Time.current, completed_at: nil)
      expect(run.duration_ms).to be_nil
    end

    it 'returns duration in milliseconds' do
      started    = Time.current
      completed  = started + 2.5
      run = build_stubbed(:ai_classifier_run, started_at: started, completed_at: completed)
      expect(run.duration_ms).to eq(2500)
    end
  end

  describe '#recipe_name' do
    it 'returns the recipe name when recipe is present' do
      recipe = build_stubbed(:recipe, name: 'Pasta Carbonara')
      run    = build_stubbed(:ai_classifier_run, recipe: recipe)
      expect(run.recipe_name).to eq('Pasta Carbonara')
    end

    it 'returns fallback text when recipe is nil' do
      run = build_stubbed(:ai_classifier_run, recipe: nil)
      expect(run.recipe_name).to eq('(recipe deleted)')
    end
  end
end
