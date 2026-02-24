module Filters
  class IngredientsFilter
    def initialize(value)
      @ingredients = value.split(/,\s*?/).map { |i| i.strip.downcase }
    end

    def apply(recipes)
      recipes.joins(:ingredients).where(query_string, *parameters)
    end

    private

    def query_string
      clauses = @ingredients.map { " lower(ingredients.name) like ? " }
      "( #{clauses.join(' OR ')} )"
    end

    def parameters
      @ingredients.map { |i| "%#{i}%" }
    end
  end
end
