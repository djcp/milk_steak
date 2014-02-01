# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:email) { |n| "email#{n}@example.com" }

  factory :user do
    email
    password 'asdASD123!@#'
  end
end
