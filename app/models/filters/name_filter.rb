module Filters
  class NameFilter
    def initialize(value)
      @value = value
    end

    def apply(recipes)
      pattern = ActiveRecord::Base.sanitize_sql_like(@value.to_s.downcase)
      recipes.where('lower(recipes.name) like ?', "%#{pattern}%")
    end
  end
end
