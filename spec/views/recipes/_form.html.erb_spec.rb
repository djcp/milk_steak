require 'spec_helper'

describe 'app/views/recipes/_form.html.erb' do
  it 'has correct multi autocompletes' do
    assign(:recipe, build(:recipe))
    render partial: 'recipes/form'

    [:cooking_method_list, :cultural_influence_list, :course_list, :dietary_restriction_list].each do |field|

      expect(rendered).to have_css("#recipe_#{field}.autocomplete_multiple")
    end
  end

  # it 'has correct single autocompletes' do
  #   assign(:recipe, build(:recipe))
  #   render partial: 'recipes/form'
  #
  #   [:cooking_method_list, :cultural_influence_list, :course_list, :dietary_restriction_list].each do |field|
  #
  #     expect(rendered).to have_css("#recipe_#{field}.autocomplete_multiple")
  #   end
  #
  # end
end
