require 'spec_helper'

describe 'app/views/recipes/_form.html.erb' do
  before do
    allow(view).to receive(:current_user).and_return(build(:user))
  end

  it 'has correct multi autocompletes' do
    assign(:recipe, build(:recipe))
    render partial: 'recipes/form'

    [:cooking_method_list, :cultural_influence_list, :course_list,
     :dietary_restriction_list].each do |field|
      expect(rendered).to have_css("#recipe_#{field}.autocomplete_multiple")
    end
  end

  it 'has correct single autocompletes' do
    assign(
      :recipe, build(
        :recipe, recipe_ingredients: build_list(:recipe_ingredient, 2)
      )
    )
    render partial: 'recipes/form'

    expect(rendered).to have_css('#recipe_serving_units.autocomplete_single')
    expect(rendered).to have_css(
      '#recipe_recipe_ingredients_attributes_0_unit.autocomplete_single'
    )
    expect(rendered).to have_css(
      '#recipe_recipe_ingredients_attributes_0_ingredient_attributes_name.autocomplete_single'
    )
  end

  context 'when user is admin' do
    before do
      allow(view).to receive(:current_user).and_return(build(:user, :admin))
    end

    it 'shows admin fields' do
      assign(:recipe, build(:recipe))
      render partial: 'recipes/form'

      expect(rendered).to have_css('#admin_fields')
      expect(rendered).to have_field('recipe[status]')
      expect(rendered).to have_field('recipe[source_url]')
      expect(rendered).to have_field('recipe[source_text]')
    end
  end

  context 'when user is not admin' do
    it 'does not show admin fields' do
      assign(:recipe, build(:recipe))
      render partial: 'recipes/form'

      expect(rendered).not_to have_css('#admin_fields')
    end
  end
end
