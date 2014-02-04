class RecipeIngredient < ActiveRecord::Base
  belongs_to :recipe
  belongs_to :ingredient

  validates :recipe, presence: true
  validates :ingredient, presence: true
  accepts_nested_attributes_for :ingredient

  acts_as_list scope: :recipe
end
