class FilterSet
  include ActiveModel::Model
  attr_accessor :cooking_methods,
    :cultural_influences,
    :courses,
    :dietary_restrictions,
    :name,
    :ingredients

  def initialize(params)
    @cooking_methods = params[:cooking_methods]
    @cultural_influences = params[:cultural_influences]
    @courses = params[:courses]
    @dietary_restrictions = params[:dietary_restrictions]
    @name = params[:name]
    @ingredients = params[:ingredients]
  end

  def apply_to(recipes)
    %i|cooking_methods cultural_influences courses dietary_restrictions|.each do |context|
      if self.send(context).present?
        tags = self.send(context).split(/,\s*?/).map{ |t| t.strip }
        recipes = recipes.tagged_with(tags, on: context, any: true)
      end
    end
    if name.present?
      recipes = recipes.where('lower(recipes.name) like ?', %Q|%#{name.downcase}%|)
    end
    if ingredients.present?
      # TODO: functional postgres index to lowercase this column
      query = ingredients_query
      recipes = recipes.joins(:ingredients).where(
        query[:query_string], *query[:parameters]
      )
    end
    recipes.distinct
  end

  private

  def ingredients_query
    queries = []
    parameters = []
    ingredients_list.each do |ingredient|
      next unless ingredient.present?
      queries << " lower(ingredients.name) like ? "
      parameters << "%#{ingredient.downcase}%"
    end
    query_string = %Q|( #{queries.join(' OR ')} )|
    { query_string: query_string, parameters: parameters}
  end

  def ingredients_list
    ingredients.split(/,\s*?/).map { |i| i.strip.downcase }
  end
end
