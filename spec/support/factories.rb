# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  sequence(:email) { |n| "email#{n}@example.com" }
  sequence(:name) { |n| "Recipe name #{n}" }
  sequence(:ingredient_name) { |n| "Ingredient name #{n}" }
  sequence(:cooking_method) { |n| "method #{n}" }
  sequence(:cultural_influence) { |n| "influence #{n}" }
  sequence(:course) { |n| "course #{n}" }
  sequence(:dietary_restriction) { |n| "restriction #{n}" }

  factory :image do
    after(:build) do |image|
      image.image.attach(
        io: File.open(Rails.root.join('spec/support/files/sample.jpg')),
        filename: 'sample.jpg',
        content_type: 'image/jpeg'
      )
    end
    recipe
    featured { false }
  end

  factory :user do
    email
    password { 'asdASD123!@#' }
    confirmed_at { Time.current }

    trait :admin do
      admin { true }
    end
  end

  factory :recipe do
    name
    directions { "Do stuff" }
    status { 'published' }
    user

    trait :draft do
      status { 'draft' }
      directions { nil }
    end

    trait :processing do
      status { 'processing' }
      directions { nil }
    end

    trait :processing_failed do
      status { 'processing_failed' }
      directions { nil }
      ai_error { 'AI extraction failed' }
    end

    trait :review do
      status { 'review' }
    end

    trait :magic do
      source_url { 'https://example.com/recipe' }
    end

    factory :full_recipe do
      after(:build) do |recipe|
        build_list(:recipe_ingredient, 2, recipe: recipe)
        recipe.cooking_method_list = 2.times.map { generate(:cooking_method) }.join(',')
        recipe.cultural_influence_list = 2.times.map { generate(:cultural_influence) }.join(',')
        recipe.course_list = 2.times.map { generate(:course) }.join(',')
        recipe.dietary_restriction_list = 2.times.map { generate(:dietary_restriction) }.join(',')
      end
    end

  end

  factory :ingredient do
    name { generate(:ingredient_name) }
  end

  factory :recipe_ingredient do
    recipe
    ingredient
    descriptor { nil }
  end
end
