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

  factory :ai_classifier_run do
    service_class { 'RecipeAiExtractor' }
    adapter       { 'anthropic' }
    ai_model      { 'claude-sonnet-4-5-20250929' }
    success       { true }
    started_at    { 5.seconds.ago }
    completed_at  { Time.current }

    trait :failed do
      success       { false }
      error_class   { 'RuntimeError' }
      error_message { 'API error' }
      raw_response  { nil }
    end

    trait :with_recipe do
      recipe
    end

    trait :text_extractor do
      service_class { 'RecipeTextExtractor' }
      adapter       { nil }
      ai_model      { nil }
    end

    trait :ai_applier do
      service_class { 'RecipeAiApplier' }
      adapter       { nil }
      ai_model      { nil }
    end
  end
end
