# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if Rails.env == 'development'
  admin = User.where(
    email: 'admin@example.com'
  ).first_or_create!(password: 'asdASD123!@#')
  admin.confirm

  Recipe.create!(
    name: 'Ice',
    cooking_method_list: 'freezing',
    cultural_influence_list: 'all the world',
    course_list: 'drinks',
    dietary_restriction_list: 'none',
    preparation_time: 1,
    cooking_time: 60,
    servings: 10,
    serving_units: 'cubes',
    directions: 'Pour water in ice cube tray. Freeze',
    user: admin,
    recipe_ingredients: [
      RecipeIngredient.new(
        quantity: 1, unit: 'quart',
        ingredient: Ingredient.where(name: 'water').first_or_create!
      )
    ]
  )

  Recipe.create!(
    name: 'Marinara Sauce',
    cooking_method_list: 'simmer, saute',
    cultural_influence_list: 'italian',
    course_list: 'pasta, dinner',
    preparation_time: 15,
    cooking_time: 60,
    servings: 6,
    serving_units: 'servings',
    directions: 'Dice garlic finely. Heat olive oil in a saucepan under medium heat for 5 minutes.
Saute garlic for 5 minutes until it starts to get sticky.

Pour in tomatoes and stir quickly into garlic oil. Bring to a boil and reduce heat to low. Put in all spices and simmer until done, 1/2 hour to an hour. Serve over pasta or use in other recipes.',
    user: admin,
    recipe_ingredients: [
      RecipeIngredient.new(
        quantity: 6, unit: 'cloves',
        ingredient: Ingredient.where(name: 'Garlic').first_or_create!
      ),
      RecipeIngredient.new(
        quantity: 1, unit: '22 oz can',
        ingredient: Ingredient.where(name: 'Crushed tomatoes').first_or_create!
      ),
      RecipeIngredient.new(
        quantity: 0.25, unit: 'cup',
        ingredient: Ingredient.where(name: 'Chopped basil').first_or_create!
      ),
      RecipeIngredient.new(
        quantity: 0.125, unit: 'cup',
        ingredient: Ingredient.where(name: 'Chopped oregano').first_or_create!
      ),
      RecipeIngredient.new(
        quantity: 1, unit: 'tsp',
        ingredient: Ingredient.where(name: 'salt').first_or_create!
      ),
      RecipeIngredient.new(
        quantity: 0.5, unit: 'tsp',
        ingredient: Ingredient.where(name: 'ground black pepper').first_or_create!
      ),
      RecipeIngredient.new(
        quantity: 0.125, unit: 'tsp',
        ingredient: Ingredient.where(name: 'cayenne pepper').first_or_create!
      ),
    ]
  )

end
