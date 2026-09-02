require 'spec_helper'

describe Autocompletes::CoursesController do
  it_behaves_like 'an autocomplete controller', seed: lambda { |recipe, value|
    recipe.course_list = value
    recipe.save!
  }
end
