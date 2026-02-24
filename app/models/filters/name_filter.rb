module Filters
  class NameFilter
    def initialize(value)
      @value = value
    end

    def apply(recipes)
      recipes.where('lower(recipes.name) like ?', "%#{@value.downcase}%")
    end
  end
end
