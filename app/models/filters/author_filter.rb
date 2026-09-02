module Filters
  class AuthorFilter
    def initialize(value)
      @value = value
    end

    def apply(recipes)
      recipes.joins(:user).where('users.username ilike ?', "%#{sanitize(@value)}%")
    end

    private

    # Bound parameters already make this injection-safe; escaping stops a
    # literal % or _ in the search term acting as a wildcard.
    def sanitize(value)
      ActiveRecord::Base.sanitize_sql_like(value.to_s)
    end
  end
end
