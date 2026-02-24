class FilterSet
  include ActiveModel::Model

  FILTERS = %i[
    cooking_methods
    cultural_influences
    courses
    dietary_restrictions
    name
    ingredients
    author
  ].freeze

  TAG_CONTEXTS = %i[cooking_methods cultural_influences courses dietary_restrictions].freeze

  attr_accessor *FILTERS

  def initialize(params)
    @cooking_methods     = normalize params[:cooking_methods]
    @cultural_influences = normalize params[:cultural_influences]
    @courses             = normalize params[:courses]
    @dietary_restrictions = normalize params[:dietary_restrictions]
    @name                = normalize params[:name]
    @ingredients         = normalize params[:ingredients]
    @author              = normalize params[:author]
  end

  def active_filters
    FILTERS.select { |filter| send(filter).present? }
  end

  def apply_to(recipes)
    active_strategies.reduce(recipes) { |r, strategy| strategy.apply(r) }.distinct
  end

  private

  def active_strategies
    tag_strategies + scalar_strategies.compact
  end

  def tag_strategies
    TAG_CONTEXTS.filter_map do |context|
      value = send(context)
      ::Filters::TagFilter.new(context, value) if value.present?
    end
  end

  def scalar_strategies
    [
      (::Filters::NameFilter.new(name)               if name.present?),
      (::Filters::IngredientsFilter.new(ingredients) if ingredients.present?),
      (::Filters::AuthorFilter.new(author)           if author.present?)
    ]
  end

  def normalize(value)
    return if value.nil?

    value.split(',').compact_blank.join(',')
  end
end
