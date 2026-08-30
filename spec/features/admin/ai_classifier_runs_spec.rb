require 'spec_helper'

feature 'Admin AI classifier runs' do
  let(:admin) { create(:user, :admin) }

  before { log_in_as(admin) }

  scenario 'index shows (recipe deleted) for a run with a nulled recipe' do
    create(:ai_classifier_run, recipe: nil)

    visit admin_ai_classifier_runs_path

    expect(page).to have_content('(recipe deleted)')
  end

  scenario 'show shows (recipe deleted) for a run with a nulled recipe' do
    run = create(:ai_classifier_run, recipe: nil)

    visit admin_ai_classifier_run_path(run)

    expect(page).to have_content('(recipe deleted)')
  end

  scenario 'index links to the recipe for a run with an associated recipe' do
    recipe = create(:recipe)
    create(:ai_classifier_run, :with_recipe, recipe: recipe)

    visit admin_ai_classifier_runs_path

    expect(page).to have_link(recipe.name, href: recipe_path(recipe))
  end
end
