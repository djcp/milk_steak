require 'spec_helper'

feature 'members get a scoped admin shell' do
  scenario 'member sees only their own recipes on the admin index' do
    user = create(:user)
    create(:recipe, name: 'My Personal Stew', user: user)
    create(:recipe, name: 'Someone Else is Soup')

    log_in_as(user)
    visit admin_recipes_path

    expect(page).to have_content('My Personal Stew')
    expect(page).not_to have_content('Someone Else is Soup')
  end

  scenario 'member can delete their own recipe from the admin index' do
    user = create(:user)
    create(:recipe, user: user)

    log_in_as(user)
    visit admin_recipes_path

    expect do
      within('tbody') { click_on 'Delete' }
    end.to change(Recipe, :count).by(-1)

    expect(page).to have_content('Recipe deleted.')
  end

  scenario 'member sees AI runs for their own recipes read-only' do
    user = create(:user)
    recipe = create(:recipe, user: user)
    recipe.update!(status: 'processing_failed')
    run = create(:ai_classifier_run, recipe: recipe)

    log_in_as(user)
    visit admin_ai_classifier_runs_path

    expect(page).to have_content('AI Runs')
    expect(page).to have_link(recipe.name, href: recipe_path(recipe))

    visit admin_ai_classifier_run_path(run)
    expect(page).not_to have_content('Rerun')
  end
end
