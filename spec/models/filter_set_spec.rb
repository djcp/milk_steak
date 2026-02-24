require 'spec_helper'

describe FilterSet do
  describe '#active_filters' do
    it 'returns empty array when no filters set' do
      expect(described_class.new({}).active_filters).to be_empty
    end

    it 'returns the names of filters with values' do
      filter_set = described_class.new(name: 'pasta', author: 'alice')
      expect(filter_set.active_filters).to contain_exactly(:name, :author)
    end
  end

  describe '#apply_to' do
    let(:base_scope) { Recipe.published }

    context 'with no filters' do
      it 'returns all recipes unchanged' do
        recipe = create(:recipe)
        result = described_class.new({}).apply_to(base_scope)
        expect(result).to include(recipe)
      end
    end

    context 'name filter' do
      it 'matches on a case-insensitive substring' do
        match    = create(:recipe, name: 'Spaghetti Carbonara')
        no_match = create(:recipe, name: 'Beef Stew')

        result = described_class.new(name: 'carbonara').apply_to(base_scope)

        expect(result).to include(match)
        expect(result).not_to include(no_match)
      end
    end

    context 'tag filters' do
      it 'filters by cooking method' do
        match    = create(:recipe, cooking_method_list: 'bake')
        no_match = create(:recipe, cooking_method_list: 'fry')

        result = described_class.new(cooking_methods: 'bake').apply_to(base_scope)

        expect(result).to include(match)
        expect(result).not_to include(no_match)
      end

      it 'filters by multiple tags using OR logic' do
        bake  = create(:recipe, cooking_method_list: 'bake')
        grill = create(:recipe, cooking_method_list: 'grill')
        fry   = create(:recipe, cooking_method_list: 'fry')

        result = described_class.new(cooking_methods: 'bake,grill').apply_to(base_scope)

        expect(result).to include(bake, grill)
        expect(result).not_to include(fry)
      end

      it 'filters by course' do
        match    = create(:recipe, course_list: 'dessert')
        no_match = create(:recipe, course_list: 'dinner')

        result = described_class.new(courses: 'dessert').apply_to(base_scope)

        expect(result).to include(match)
        expect(result).not_to include(no_match)
      end
    end

    context 'ingredients filter' do
      it 'matches recipes containing the ingredient' do
        flour    = Ingredient.create!(name: 'flour')
        match    = create(:recipe)
        no_match = create(:recipe)
        create(:recipe_ingredient, recipe: match, ingredient: flour)

        result = described_class.new(ingredients: 'flour').apply_to(base_scope)

        expect(result).to include(match)
        expect(result).not_to include(no_match)
      end

      it 'is case-insensitive' do
        flour = Ingredient.create!(name: 'flour')
        match = create(:recipe)
        create(:recipe_ingredient, recipe: match, ingredient: flour)

        result = described_class.new(ingredients: 'FLOUR').apply_to(base_scope)
        expect(result).to include(match)
      end
    end

    context 'author filter' do
      it 'matches on a case-insensitive username substring' do
        alice    = create(:user, username: 'alice_cooks')
        bob      = create(:user, username: 'bob_eats')
        match    = create(:recipe, user: alice)
        no_match = create(:recipe, user: bob)

        result = described_class.new(author: 'alice').apply_to(base_scope)

        expect(result).to include(match)
        expect(result).not_to include(no_match)
      end
    end

    context 'multiple filters combined' do
      it 'applies all active filters as AND conditions' do
        user         = create(:user, username: 'chefdan')
        match        = create(:recipe, name: 'Bread', user: user, cooking_method_list: 'bake')
        _wrong_author = create(:recipe, name: 'Bread', cooking_method_list: 'bake')

        result = described_class.new(
          name: 'bread', author: 'chefdan', cooking_methods: 'bake'
        ).apply_to(base_scope)

        expect(result).to contain_exactly(match)
      end
    end
  end
end
