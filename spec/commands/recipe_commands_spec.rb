require 'spec_helper'

describe RecipeCommands do
  describe RecipeCommands::Publish do
    context 'when recipe is publishable' do
      it 'updates status to published and returns success' do
        recipe = create(:recipe, status: 'review')
        result = described_class.new(recipe).call

        expect(recipe.reload.status).to eq('published')
        expect(result.success).to be true
        expect(result.message).to eq('Recipe published.')
        expect(result.flash_type).to eq(:notice)
      end
    end

    context 'when recipe is not publishable' do
      it 'leaves status unchanged and returns failure' do
        recipe = create(:recipe, :draft)
        result = described_class.new(recipe).call

        expect(recipe.reload.status).to eq('draft')
        expect(result.success).to be false
        expect(result.flash_type).to eq(:alert)
      end
    end
  end

  describe RecipeCommands::Reject do
    it 'updates status to rejected and returns success' do
      recipe = create(:recipe, status: 'review')
      result = described_class.new(recipe).call

      expect(recipe.reload.status).to eq('rejected')
      expect(result.success).to be true
      expect(result.message).to eq('Recipe rejected.')
      expect(result.flash_type).to eq(:notice)
    end
  end

  describe RecipeCommands::Reprocess do
    context 'when recipe is reprocessable' do
      it 'enqueues MagicRecipeJob and returns success' do
        recipe = create(:recipe, :processing_failed, :magic)
        result = nil

        expect { result = described_class.new(recipe).call }
          .to have_enqueued_job(MagicRecipeJob).with(recipe.id)

        expect(result.success).to be true
        expect(result.message).to eq('Recipe re-enqueued for processing.')
      end
    end

    context 'when recipe is not reprocessable' do
      it 'does not enqueue a job and returns failure' do
        recipe = create(:recipe, :draft)
        result = nil

        expect { result = described_class.new(recipe).call }
          .not_to have_enqueued_job(MagicRecipeJob)

        expect(result.success).to be false
        expect(result.flash_type).to eq(:alert)
      end
    end
  end

  describe RecipeCommands::Destroy do
    it 'destroys the recipe and returns success' do
      recipe = Recipe.includes(:images, :recipe_ingredients, :ingredients).find(create(:recipe).id)
      result = described_class.new(recipe).call

      expect { recipe.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect(result.success).to be true
      expect(result.message).to eq('Recipe deleted.')
    end
  end
end
