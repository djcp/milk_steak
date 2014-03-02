require 'spec_helper'

describe 'app/views/recipes/_form.html.erb' do
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
end
