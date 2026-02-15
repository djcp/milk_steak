# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if Rails.env == 'development'
  admin = User.find_or_initialize_by(email: 'admin@example.com')
  if admin.new_record?
    admin.password = 'asdASD123!@#'
    admin.skip_confirmation!
    admin.save!
  end

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

  Recipe.create!(
    name: 'Chicken Tikka Masala',
    cooking_method_list: 'roast, simmer, marinate',
    cultural_influence_list: 'indian',
    course_list: 'dinner, entree',
    dietary_restriction_list: 'gluten-free',
    preparation_time: 30,
    cooking_time: 40,
    servings: 4,
    serving_units: 'servings',
    directions: 'Cut chicken into bite-sized pieces and marinate in yogurt, lemon juice, garam masala, cumin, and salt for at least 1 hour.

Roast marinated chicken in a 450F oven for 15 minutes until charred at the edges.

In a large skillet, heat butter and saute onion until soft. Add garlic and ginger, cook 1 minute. Stir in tomato paste, garam masala, cumin, and chili powder. Pour in crushed tomatoes and simmer 15 minutes.

Stir in cream and the roasted chicken. Simmer 10 minutes. Finish with fresh cilantro and serve over basmati rice.',
    user: admin,
    recipe_ingredients: [
      RecipeIngredient.new(quantity: 1.5, unit: 'lbs', ingredient: Ingredient.where(name: 'boneless chicken thighs').first_or_create!),
      RecipeIngredient.new(quantity: 0.75, unit: 'cup', ingredient: Ingredient.where(name: 'plain yogurt').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'tbsp', ingredient: Ingredient.where(name: 'lemon juice').first_or_create!),
      RecipeIngredient.new(quantity: 2, unit: 'tsp', ingredient: Ingredient.where(name: 'garam masala').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'tsp', ingredient: Ingredient.where(name: 'ground cumin').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'large', ingredient: Ingredient.where(name: 'yellow onion').first_or_create!),
      RecipeIngredient.new(quantity: 3, unit: 'cloves', ingredient: Ingredient.where(name: 'Garlic').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'tbsp', ingredient: Ingredient.where(name: 'fresh ginger').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: '14 oz can', ingredient: Ingredient.where(name: 'Crushed tomatoes').first_or_create!),
      RecipeIngredient.new(quantity: 0.75, unit: 'cup', ingredient: Ingredient.where(name: 'heavy cream').first_or_create!),
      RecipeIngredient.new(quantity: 2, unit: 'tbsp', ingredient: Ingredient.where(name: 'butter').first_or_create!),
      RecipeIngredient.new(quantity: 0.25, unit: 'cup', ingredient: Ingredient.where(name: 'fresh cilantro').first_or_create!),
    ]
  )

  Recipe.create!(
    name: 'Guacamole',
    cooking_method_list: 'raw, mixing',
    cultural_influence_list: 'mexican',
    course_list: 'appetizer, snack, side',
    dietary_restriction_list: 'vegan, gluten-free, dairy-free',
    preparation_time: 15,
    cooking_time: 0,
    servings: 4,
    serving_units: 'servings',
    directions: 'Halve avocados and remove pits. Scoop flesh into a bowl and mash with a fork to desired consistency.

Fold in diced onion, tomato, jalapeno, cilantro, and lime juice. Season with salt and cumin. Taste and adjust seasoning.

Serve immediately with tortilla chips or as a topping.',
    user: admin,
    recipe_ingredients: [
      RecipeIngredient.new(quantity: 3, unit: 'medium', ingredient: Ingredient.where(name: 'ripe avocados').first_or_create!),
      RecipeIngredient.new(quantity: 0.5, unit: 'small', ingredient: Ingredient.where(name: 'white onion').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'medium', ingredient: Ingredient.where(name: 'roma tomato').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'small', ingredient: Ingredient.where(name: 'jalapeno').first_or_create!),
      RecipeIngredient.new(quantity: 0.25, unit: 'cup', ingredient: Ingredient.where(name: 'fresh cilantro').first_or_create!),
      RecipeIngredient.new(quantity: 2, unit: 'tbsp', ingredient: Ingredient.where(name: 'lime juice').first_or_create!),
      RecipeIngredient.new(quantity: 0.5, unit: 'tsp', ingredient: Ingredient.where(name: 'salt').first_or_create!),
      RecipeIngredient.new(quantity: 0.25, unit: 'tsp', ingredient: Ingredient.where(name: 'ground cumin').first_or_create!),
    ]
  )

  Recipe.create!(
    name: 'Cacio e Pepe',
    cooking_method_list: 'boil, toss',
    cultural_influence_list: 'italian, roman',
    course_list: 'dinner, pasta',
    dietary_restriction_list: 'vegetarian',
    preparation_time: 5,
    cooking_time: 15,
    servings: 4,
    serving_units: 'servings',
    directions: 'Bring a large pot of salted water to a boil. Cook spaghetti until just shy of al dente, reserving 2 cups of pasta water before draining.

Toast freshly cracked black pepper in a dry skillet over medium heat for 1-2 minutes until fragrant. Add 1 cup pasta water and bring to a simmer.

Add the drained pasta and toss vigorously. Remove from heat and add Pecorino Romano a handful at a time, tossing constantly and adding splashes of pasta water to create a creamy sauce. Serve immediately with extra cheese and pepper.',
    user: admin,
    recipe_ingredients: [
      RecipeIngredient.new(quantity: 1, unit: 'lb', ingredient: Ingredient.where(name: 'spaghetti').first_or_create!),
      RecipeIngredient.new(quantity: 2, unit: 'cups', ingredient: Ingredient.where(name: 'Pecorino Romano').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'tbsp', ingredient: Ingredient.where(name: 'whole black peppercorns').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'tsp', ingredient: Ingredient.where(name: 'salt').first_or_create!),
    ]
  )

  Recipe.create!(
    name: 'Chana Masala',
    cooking_method_list: 'saute, simmer',
    cultural_influence_list: 'indian, punjabi',
    course_list: 'dinner, lunch, entree',
    dietary_restriction_list: 'vegan, gluten-free, dairy-free',
    preparation_time: 10,
    cooking_time: 35,
    servings: 6,
    serving_units: 'servings',
    directions: 'Heat oil in a large pot over medium heat. Add onion and cook until golden, about 8 minutes. Add garlic, ginger, and serrano pepper, cook 2 minutes.

Stir in cumin, coriander, turmeric, garam masala, and chili powder. Toast spices for 1 minute. Add diced tomatoes and cook until they break down, about 5 minutes.

Add drained chickpeas and 1 cup water. Simmer 20 minutes until sauce thickens. Stir in lemon juice and cilantro. Season with salt. Serve with rice or naan.',
    user: admin,
    recipe_ingredients: [
      RecipeIngredient.new(quantity: 2, unit: '15 oz cans', ingredient: Ingredient.where(name: 'chickpeas').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'large', ingredient: Ingredient.where(name: 'yellow onion').first_or_create!),
      RecipeIngredient.new(quantity: 4, unit: 'cloves', ingredient: Ingredient.where(name: 'Garlic').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'tbsp', ingredient: Ingredient.where(name: 'fresh ginger').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'small', ingredient: Ingredient.where(name: 'serrano pepper').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: '14 oz can', ingredient: Ingredient.where(name: 'diced tomatoes').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'tsp', ingredient: Ingredient.where(name: 'ground cumin').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'tsp', ingredient: Ingredient.where(name: 'ground coriander').first_or_create!),
      RecipeIngredient.new(quantity: 0.5, unit: 'tsp', ingredient: Ingredient.where(name: 'ground turmeric').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'tsp', ingredient: Ingredient.where(name: 'garam masala').first_or_create!),
      RecipeIngredient.new(quantity: 2, unit: 'tbsp', ingredient: Ingredient.where(name: 'vegetable oil').first_or_create!),
      RecipeIngredient.new(quantity: 2, unit: 'tbsp', ingredient: Ingredient.where(name: 'lemon juice').first_or_create!),
      RecipeIngredient.new(quantity: 0.25, unit: 'cup', ingredient: Ingredient.where(name: 'fresh cilantro').first_or_create!),
    ]
  )

  Recipe.create!(
    name: 'Carnitas',
    cooking_method_list: 'braise, roast',
    cultural_influence_list: 'mexican, michoacan',
    course_list: 'dinner, entree',
    dietary_restriction_list: 'gluten-free, dairy-free',
    preparation_time: 15,
    cooking_time: 210,
    servings: 8,
    serving_units: 'servings',
    directions: 'Cut pork shoulder into 2-inch chunks. Season generously with salt, pepper, cumin, and oregano.

Place pork in a Dutch oven with onion, garlic, orange juice, lime juice, and bay leaves. Add enough water to come halfway up the pork. Bring to a boil, reduce to a low simmer, cover and cook 2.5 hours until fork-tender.

Uncover, increase heat to medium-high, and cook until liquid evaporates and pork begins to fry in its own fat. Shred with forks and let pieces crisp in the fat.

Alternatively, spread shredded pork on a sheet pan and broil 3-5 minutes until edges are crispy. Serve in warm tortillas with onion, cilantro, and salsa verde.',
    user: admin,
    recipe_ingredients: [
      RecipeIngredient.new(quantity: 3, unit: 'lbs', ingredient: Ingredient.where(name: 'pork shoulder').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'large', ingredient: Ingredient.where(name: 'yellow onion').first_or_create!),
      RecipeIngredient.new(quantity: 5, unit: 'cloves', ingredient: Ingredient.where(name: 'Garlic').first_or_create!),
      RecipeIngredient.new(quantity: 0.5, unit: 'cup', ingredient: Ingredient.where(name: 'orange juice').first_or_create!),
      RecipeIngredient.new(quantity: 2, unit: 'tbsp', ingredient: Ingredient.where(name: 'lime juice').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'tbsp', ingredient: Ingredient.where(name: 'ground cumin').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'tbsp', ingredient: Ingredient.where(name: 'dried oregano').first_or_create!),
      RecipeIngredient.new(quantity: 2, unit: 'whole', ingredient: Ingredient.where(name: 'bay leaves').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'tsp', ingredient: Ingredient.where(name: 'salt').first_or_create!),
      RecipeIngredient.new(quantity: 0.5, unit: 'tsp', ingredient: Ingredient.where(name: 'ground black pepper').first_or_create!),
    ]
  )

  Recipe.create!(
    name: 'Palak Paneer',
    cooking_method_list: 'saute, blanch, blend',
    cultural_influence_list: 'indian, north indian',
    course_list: 'dinner, lunch, entree',
    dietary_restriction_list: 'vegetarian, gluten-free',
    preparation_time: 20,
    cooking_time: 25,
    servings: 4,
    serving_units: 'servings',
    directions: 'Blanch spinach in boiling water for 2 minutes, then transfer to an ice bath. Drain and blend into a smooth puree.

Cut paneer into 1-inch cubes and pan-fry in oil until golden on all sides. Set aside.

In the same pan, heat butter. Add cumin seeds and let them sputter. Add onion and cook until golden. Add garlic, ginger, and green chili, cook 2 minutes. Stir in coriander, cumin, turmeric, and garam masala.

Add the spinach puree and simmer 5 minutes. Stir in cream and the fried paneer. Cook 5 minutes more. Season with salt and serve with naan or rice.',
    user: admin,
    recipe_ingredients: [
      RecipeIngredient.new(quantity: 1, unit: 'lb', ingredient: Ingredient.where(name: 'fresh spinach').first_or_create!),
      RecipeIngredient.new(quantity: 8, unit: 'oz', ingredient: Ingredient.where(name: 'paneer').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'medium', ingredient: Ingredient.where(name: 'yellow onion').first_or_create!),
      RecipeIngredient.new(quantity: 3, unit: 'cloves', ingredient: Ingredient.where(name: 'Garlic').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'inch piece', ingredient: Ingredient.where(name: 'fresh ginger').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'small', ingredient: Ingredient.where(name: 'green chili').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'tsp', ingredient: Ingredient.where(name: 'ground cumin').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'tsp', ingredient: Ingredient.where(name: 'ground coriander').first_or_create!),
      RecipeIngredient.new(quantity: 0.5, unit: 'tsp', ingredient: Ingredient.where(name: 'ground turmeric').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'tsp', ingredient: Ingredient.where(name: 'garam masala').first_or_create!),
      RecipeIngredient.new(quantity: 2, unit: 'tbsp', ingredient: Ingredient.where(name: 'butter').first_or_create!),
      RecipeIngredient.new(quantity: 0.25, unit: 'cup', ingredient: Ingredient.where(name: 'heavy cream').first_or_create!),
    ]
  )

  Recipe.create!(
    name: 'Enchiladas Rojas',
    cooking_method_list: 'bake, simmer, fry',
    cultural_influence_list: 'mexican',
    course_list: 'dinner, entree',
    dietary_restriction_list: 'gluten-free',
    preparation_time: 25,
    cooking_time: 30,
    servings: 6,
    serving_units: 'enchiladas',
    directions: 'Toast dried guajillo and ancho chiles in a dry skillet until fragrant, about 1 minute per side. Remove stems and seeds, then soak in hot water for 20 minutes.

Blend soaked chiles with garlic, cumin, oregano, and 1 cup soaking liquid until smooth. Strain through a sieve. Simmer sauce in a skillet with oil for 10 minutes.

Shred cooked chicken and mix with half the sauce and diced onion. Briefly fry corn tortillas in oil to soften. Fill each tortilla with chicken mixture, roll up, and place seam-side down in a baking dish.

Pour remaining sauce over enchiladas, top with crumbled queso fresco, and bake at 375F for 20 minutes. Garnish with cilantro and crema.',
    user: admin,
    recipe_ingredients: [
      RecipeIngredient.new(quantity: 2, unit: 'cups', ingredient: Ingredient.where(name: 'shredded chicken').first_or_create!),
      RecipeIngredient.new(quantity: 6, unit: 'whole', ingredient: Ingredient.where(name: 'dried guajillo chiles').first_or_create!),
      RecipeIngredient.new(quantity: 2, unit: 'whole', ingredient: Ingredient.where(name: 'dried ancho chiles').first_or_create!),
      RecipeIngredient.new(quantity: 3, unit: 'cloves', ingredient: Ingredient.where(name: 'Garlic').first_or_create!),
      RecipeIngredient.new(quantity: 12, unit: 'whole', ingredient: Ingredient.where(name: 'corn tortillas').first_or_create!),
      RecipeIngredient.new(quantity: 0.5, unit: 'cup', ingredient: Ingredient.where(name: 'queso fresco').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'tsp', ingredient: Ingredient.where(name: 'ground cumin').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'tsp', ingredient: Ingredient.where(name: 'dried oregano').first_or_create!),
      RecipeIngredient.new(quantity: 0.5, unit: 'medium', ingredient: Ingredient.where(name: 'white onion').first_or_create!),
      RecipeIngredient.new(quantity: 3, unit: 'tbsp', ingredient: Ingredient.where(name: 'vegetable oil').first_or_create!),
    ]
  )

  Recipe.create!(
    name: 'Risotto alla Milanese',
    cooking_method_list: 'saute, simmer, stir',
    cultural_influence_list: 'italian, milanese',
    course_list: 'dinner, side, primo',
    dietary_restriction_list: 'vegetarian, gluten-free',
    preparation_time: 10,
    cooking_time: 30,
    servings: 4,
    serving_units: 'servings',
    directions: 'Warm broth in a saucepan and keep at a low simmer. Steep saffron threads in 0.5 cup of the warm broth.

In a heavy-bottomed pot, melt half the butter and saute onion until translucent, about 4 minutes. Add rice and stir 2 minutes until edges are translucent.

Add wine and stir until absorbed. Add warm broth one ladle at a time, stirring frequently and waiting until each addition is absorbed before adding the next. After about 18 minutes the rice should be creamy and al dente.

Stir in the saffron broth, remaining butter, and Parmigiano-Reggiano. Season with salt and pepper. Cover and rest 2 minutes before serving.',
    user: admin,
    recipe_ingredients: [
      RecipeIngredient.new(quantity: 1.5, unit: 'cups', ingredient: Ingredient.where(name: 'arborio rice').first_or_create!),
      RecipeIngredient.new(quantity: 5, unit: 'cups', ingredient: Ingredient.where(name: 'vegetable broth').first_or_create!),
      RecipeIngredient.new(quantity: 0.25, unit: 'tsp', ingredient: Ingredient.where(name: 'saffron threads').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'small', ingredient: Ingredient.where(name: 'yellow onion').first_or_create!),
      RecipeIngredient.new(quantity: 0.5, unit: 'cup', ingredient: Ingredient.where(name: 'dry white wine').first_or_create!),
      RecipeIngredient.new(quantity: 3, unit: 'tbsp', ingredient: Ingredient.where(name: 'butter').first_or_create!),
      RecipeIngredient.new(quantity: 0.75, unit: 'cup', ingredient: Ingredient.where(name: 'Parmigiano-Reggiano').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'tsp', ingredient: Ingredient.where(name: 'salt').first_or_create!),
    ]
  )

  Recipe.create!(
    name: 'Dal Tadka',
    cooking_method_list: 'boil, simmer, temper',
    cultural_influence_list: 'indian, north indian',
    course_list: 'dinner, lunch, side',
    dietary_restriction_list: 'vegan, gluten-free, dairy-free',
    preparation_time: 10,
    cooking_time: 35,
    servings: 4,
    serving_units: 'servings',
    directions: 'Rinse toor dal and add to a pot with water, turmeric, and salt. Bring to a boil, skim foam, then reduce heat and simmer 25-30 minutes until dal is soft and breaking apart. Mash lightly with a spoon.

For the tadka: heat ghee or oil in a small pan. Add mustard seeds and wait for them to pop. Add cumin seeds, dried red chiles, and curry leaves. Fry 30 seconds until fragrant.

Add diced onion and cook until golden. Add garlic, ginger, and tomato, cook 3 minutes. Stir in chili powder and asafoetida.

Pour the tadka over the cooked dal and stir well. Simmer together 5 minutes. Finish with fresh cilantro and a squeeze of lemon. Serve over rice.',
    user: admin,
    recipe_ingredients: [
      RecipeIngredient.new(quantity: 1, unit: 'cup', ingredient: Ingredient.where(name: 'toor dal').first_or_create!),
      RecipeIngredient.new(quantity: 3, unit: 'cups', ingredient: Ingredient.where(name: 'water').first_or_create!),
      RecipeIngredient.new(quantity: 0.5, unit: 'tsp', ingredient: Ingredient.where(name: 'ground turmeric').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'tsp', ingredient: Ingredient.where(name: 'mustard seeds').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'tsp', ingredient: Ingredient.where(name: 'cumin seeds').first_or_create!),
      RecipeIngredient.new(quantity: 2, unit: 'whole', ingredient: Ingredient.where(name: 'dried red chiles').first_or_create!),
      RecipeIngredient.new(quantity: 8, unit: 'leaves', ingredient: Ingredient.where(name: 'curry leaves').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'medium', ingredient: Ingredient.where(name: 'yellow onion').first_or_create!),
      RecipeIngredient.new(quantity: 3, unit: 'cloves', ingredient: Ingredient.where(name: 'Garlic').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'tbsp', ingredient: Ingredient.where(name: 'fresh ginger').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'medium', ingredient: Ingredient.where(name: 'roma tomato').first_or_create!),
      RecipeIngredient.new(quantity: 2, unit: 'tbsp', ingredient: Ingredient.where(name: 'vegetable oil').first_or_create!),
      RecipeIngredient.new(quantity: 0.25, unit: 'cup', ingredient: Ingredient.where(name: 'fresh cilantro').first_or_create!),
    ]
  )

  Recipe.create!(
    name: 'Elote (Mexican Street Corn)',
    cooking_method_list: 'grill, char',
    cultural_influence_list: 'mexican',
    course_list: 'side, snack, appetizer',
    dietary_restriction_list: 'vegetarian, gluten-free',
    preparation_time: 10,
    cooking_time: 10,
    servings: 4,
    serving_units: 'ears',
    directions: 'Shuck corn and grill over high heat, turning occasionally, until charred in spots all around, about 8-10 minutes.

Mix mayonnaise and crema together. While corn is still hot, brush generously with the mayo-crema mixture. Squeeze lime juice over each ear.

Roll corn in crumbled cotija cheese, then dust with chili powder. Sprinkle with fresh cilantro and serve immediately with lime wedges.',
    user: admin,
    recipe_ingredients: [
      RecipeIngredient.new(quantity: 4, unit: 'ears', ingredient: Ingredient.where(name: 'corn on the cob').first_or_create!),
      RecipeIngredient.new(quantity: 0.25, unit: 'cup', ingredient: Ingredient.where(name: 'mayonnaise').first_or_create!),
      RecipeIngredient.new(quantity: 0.25, unit: 'cup', ingredient: Ingredient.where(name: 'Mexican crema').first_or_create!),
      RecipeIngredient.new(quantity: 0.5, unit: 'cup', ingredient: Ingredient.where(name: 'cotija cheese').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'tsp', ingredient: Ingredient.where(name: 'chili powder').first_or_create!),
      RecipeIngredient.new(quantity: 2, unit: 'tbsp', ingredient: Ingredient.where(name: 'lime juice').first_or_create!),
      RecipeIngredient.new(quantity: 2, unit: 'tbsp', ingredient: Ingredient.where(name: 'fresh cilantro').first_or_create!),
    ]
  )

  Recipe.create!(
    name: 'Penne alla Vodka',
    cooking_method_list: 'boil, saute, simmer',
    cultural_influence_list: 'italian, italian-american',
    course_list: 'dinner, pasta',
    preparation_time: 10,
    cooking_time: 25,
    servings: 4,
    serving_units: 'servings',
    directions: 'Cook penne in well-salted boiling water until al dente. Reserve 1 cup pasta water before draining.

In a large skillet, heat olive oil and saute garlic 1 minute. Add red pepper flakes and cook 30 seconds. Add tomato paste and stir constantly for 2 minutes until it darkens slightly.

Pour in vodka carefully and cook until reduced by half, about 2 minutes. Add crushed tomatoes and simmer 10 minutes.

Reduce heat to low and stir in heavy cream. Add the drained pasta and toss, adding pasta water as needed. Finish with Parmigiano-Reggiano and fresh basil.',
    user: admin,
    recipe_ingredients: [
      RecipeIngredient.new(quantity: 1, unit: 'lb', ingredient: Ingredient.where(name: 'penne').first_or_create!),
      RecipeIngredient.new(quantity: 2, unit: 'tbsp', ingredient: Ingredient.where(name: 'olive oil').first_or_create!),
      RecipeIngredient.new(quantity: 3, unit: 'cloves', ingredient: Ingredient.where(name: 'Garlic').first_or_create!),
      RecipeIngredient.new(quantity: 0.5, unit: 'tsp', ingredient: Ingredient.where(name: 'red pepper flakes').first_or_create!),
      RecipeIngredient.new(quantity: 3, unit: 'tbsp', ingredient: Ingredient.where(name: 'tomato paste').first_or_create!),
      RecipeIngredient.new(quantity: 0.5, unit: 'cup', ingredient: Ingredient.where(name: 'vodka').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: '14 oz can', ingredient: Ingredient.where(name: 'Crushed tomatoes').first_or_create!),
      RecipeIngredient.new(quantity: 0.75, unit: 'cup', ingredient: Ingredient.where(name: 'heavy cream').first_or_create!),
      RecipeIngredient.new(quantity: 0.5, unit: 'cup', ingredient: Ingredient.where(name: 'Parmigiano-Reggiano').first_or_create!),
      RecipeIngredient.new(quantity: 0.25, unit: 'cup', ingredient: Ingredient.where(name: 'Chopped basil').first_or_create!),
    ]
  )

  Recipe.create!(
    name: 'Pozole Rojo',
    cooking_method_list: 'simmer, toast, blend',
    cultural_influence_list: 'mexican, guerrero',
    course_list: 'dinner, soup',
    dietary_restriction_list: 'gluten-free, dairy-free',
    preparation_time: 20,
    cooking_time: 90,
    servings: 8,
    serving_units: 'bowls',
    directions: 'Place pork shoulder in a large pot, cover with water, and add half the onion, 3 garlic cloves, and bay leaves. Bring to a boil, skim foam, then simmer 1.5 hours until pork is tender. Remove pork and shred. Strain and reserve the broth.

Toast guajillo and ancho chiles in a dry skillet. Remove stems and seeds, soak in hot water 20 minutes. Blend with remaining garlic, cumin, oregano, and 1 cup soaking liquid until smooth. Strain.

In the pot, heat oil and fry the chile sauce for 5 minutes. Add reserved broth, shredded pork, and drained hominy. Simmer 30 minutes.

Serve in bowls with shredded cabbage, sliced radishes, diced onion, dried oregano, lime wedges, and tostadas.',
    user: admin,
    recipe_ingredients: [
      RecipeIngredient.new(quantity: 2, unit: 'lbs', ingredient: Ingredient.where(name: 'pork shoulder').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: '29 oz can', ingredient: Ingredient.where(name: 'hominy').first_or_create!),
      RecipeIngredient.new(quantity: 5, unit: 'whole', ingredient: Ingredient.where(name: 'dried guajillo chiles').first_or_create!),
      RecipeIngredient.new(quantity: 2, unit: 'whole', ingredient: Ingredient.where(name: 'dried ancho chiles').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'large', ingredient: Ingredient.where(name: 'white onion').first_or_create!),
      RecipeIngredient.new(quantity: 5, unit: 'cloves', ingredient: Ingredient.where(name: 'Garlic').first_or_create!),
      RecipeIngredient.new(quantity: 2, unit: 'whole', ingredient: Ingredient.where(name: 'bay leaves').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'tsp', ingredient: Ingredient.where(name: 'ground cumin').first_or_create!),
      RecipeIngredient.new(quantity: 1, unit: 'tbsp', ingredient: Ingredient.where(name: 'dried oregano').first_or_create!),
      RecipeIngredient.new(quantity: 2, unit: 'tbsp', ingredient: Ingredient.where(name: 'vegetable oil').first_or_create!),
    ]
  )

end
