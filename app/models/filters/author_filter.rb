module Filters
  class AuthorFilter
    def initialize(value)
      @value = value
    end

    def apply(recipes)
      recipes.joins(:user).where('users.username ilike ?', "%#{@value}%")
    end
  end
end
