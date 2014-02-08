# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:email) { |n| "email#{n}@example.com" }
  sequence(:name) { |n| "Recipe name #{n}" }
  sequence(:ingredient_name) { |n| "Ingredient name #{n}" }

  factory :user do
    email
    password 'asdASD123!@#'
  end

  factory :recipe do
    name
    directions "Do stuff"
  end

  factory :ingredient do
    name { generate(:ingredient_name) }
  end

  factory :recipe_ingredient do
    recipe
    ingredient
  end
end
