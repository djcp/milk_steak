class RecipeOnPage
  include Capybara::DSL

  def fill_in_main_form_with(attributes = {})
    attributes.each do |k, v|
      fill_in(k, with: v)
    end
  end

  def fill_in_ingredients_with(value)

  end
end
