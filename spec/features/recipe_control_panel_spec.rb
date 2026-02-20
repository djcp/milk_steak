require 'spec_helper'

feature 'Recipe control panel' do
  let(:author) { create(:user) }
  let(:recipe) { create(:recipe, user: author) }

  context 'when not logged in' do
    scenario 'does not show any controls' do
      visit recipe_path(recipe)
      expect(page).not_to have_css('#control-panel')
    end
  end

  context 'when logged in as a non-owner, non-admin user' do
    scenario 'does not show any controls' do
      log_in_as(create(:user))
      visit recipe_path(recipe)
      expect(page).not_to have_css('#control-panel')
    end
  end

  context 'when logged in as the recipe owner' do
    before { log_in_as(author) }

    scenario 'shows an edit link' do
      visit recipe_path(recipe)
      within('#control-panel') do
        expect(page).to have_link('Edit', href: edit_recipe_path(recipe))
      end
    end

    scenario 'does not show admin controls' do
      visit recipe_path(recipe)
      within('#control-panel') do
        expect(page).not_to have_text('Status:')
        expect(page).not_to have_button('Publish')
        expect(page).not_to have_button('Reject')
        expect(page).not_to have_button('Reprocess')
        expect(page).not_to have_button('Delete')
      end
    end
  end

  context 'when logged in as an admin' do
    let(:admin) { create(:user, :admin) }
    before { log_in_as(admin) }

    scenario 'shows the status badge and edit/delete for a published recipe' do
      visit recipe_path(recipe)
      within('#control-panel') do
        expect(page).to have_text('Status:')
        expect(page).to have_text('published')
        expect(page).to have_link('Edit', href: edit_recipe_path(recipe))
        expect(page).to have_button('Delete')
        expect(page).not_to have_button('Publish')
        expect(page).not_to have_button('Reject')
        expect(page).not_to have_button('Reprocess')
      end
    end

    context 'with a recipe awaiting review' do
      let(:recipe) { create(:recipe, :review, user: author) }

      scenario 'shows Publish and Reject but not Reprocess' do
        visit recipe_path(recipe)
        within('#control-panel') do
          expect(page).to have_button('Publish')
          expect(page).to have_button('Reject')
          expect(page).not_to have_button('Reprocess')
        end
      end

      scenario 'publishing marks the recipe as published' do
        visit recipe_path(recipe)
        click_button 'Publish'
        expect(recipe.reload.status).to eq('published')
        expect(page).to have_current_path(recipe_path(recipe))
      end

      scenario 'rejecting marks the recipe as rejected' do
        visit recipe_path(recipe)
        click_button 'Reject'
        expect(recipe.reload.status).to eq('rejected')
        expect(page).to have_current_path(recipe_path(recipe))
      end
    end

    context 'with a processing_failed recipe' do
      let(:recipe) { create(:recipe, :processing_failed, user: author) }

      scenario 'shows Reprocess but not Publish or Reject' do
        visit recipe_path(recipe)
        within('#control-panel') do
          expect(page).to have_button('Reprocess')
          expect(page).not_to have_button('Publish')
          expect(page).not_to have_button('Reject')
        end
      end

      scenario 'reprocessing enqueues a MagicRecipeJob' do
        allow(MagicRecipeJob).to receive(:perform_later)
        visit recipe_path(recipe)
        click_button 'Reprocess'
        expect(MagicRecipeJob).to have_received(:perform_later).with(recipe.id)
      end
    end

    context 'with a draft recipe' do
      let(:recipe) { create(:recipe, :draft, user: author) }

      scenario 'shows only edit and delete' do
        visit recipe_path(recipe)
        within('#control-panel') do
          expect(page).to have_link('Edit')
          expect(page).to have_button('Delete')
          expect(page).not_to have_button('Publish')
          expect(page).not_to have_button('Reject')
          expect(page).not_to have_button('Reprocess')
        end
      end
    end

    scenario 'deleting a recipe destroys it and redirects to admin index' do
      visit recipe_path(recipe)
      click_button 'Delete'
      expect(Recipe.find_by(id: recipe.id)).to be_nil
      expect(page).to have_current_path(admin_recipes_path)
    end
  end
end
