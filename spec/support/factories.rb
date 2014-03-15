# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:email) { |n| "email#{n}@example.com" }
  sequence(:name) { |n| "Recipe name #{n}" }
  sequence(:ingredient_name) { |n| "Ingredient name #{n}" }
  sequence(:cooking_method) { |n| "method #{n}" }
  sequence(:cultural_influence) { |n| "influence #{n}" }
  sequence(:course) { |n| "course #{n}" }
  sequence(:dietary_restriction) { |n| "restriction #{n}" }

  factory :image do
    filepicker_url "MyString"
    recipe
    featured false
  end

  factory :user do
    email
    password 'asdASD123!@#'
  end

  factory :recipe do
    name
    directions "Do stuff"

    factory :full_recipe do
      after(:build) do |recipe|
        build_list(:recipe_ingredient, 2, recipe: recipe)
        recipe.cooking_method_list = 2.times.map { generate(:cooking_method) }.join(',') 
        recipe.cultural_influence_list = 2.times.map { generate(:cultural_influence) }.join(',')
        recipe.course_list = 2.times.map { generate(:course) }.join(',')
        recipe.dietary_restriction_list =  2.times.map { generate(:dietary_restriction) }.join(',')
      end
    end

  end

  factory :ingredient do
    name { generate(:ingredient_name) }
  end

  factory :recipe_ingredient do
    recipe
    ingredient
  end
end
