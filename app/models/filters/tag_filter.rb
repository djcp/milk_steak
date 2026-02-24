module Filters
  class TagFilter
    def initialize(context, value)
      @context = context
      @tags = value.split(/,\s*?/).map(&:strip)
    end

    def apply(recipes)
      recipes.tagged_with(@tags, on: @context, any: true)
    end
  end
end
