class RecipeTextExtractor
  MAX_TEXT_LENGTH = 15_000

  MAIN_CONTENT_SELECTORS = %w[
    article [role="main"] main .recipe .entry-content .post-content
  ].freeze

  SCHEMA_FIELDS = %w[name description prepTime cookTime recipeYield].freeze
  SCHEMA_LABELS = { 'name' => 'Name', 'description' => 'Description',
                    'prepTime' => 'Prep Time', 'cookTime' => 'Cook Time',
                    'recipeYield' => 'Yield' }.freeze

  def self.from_url(url)
    new(url).extract
  end

  def initialize(url)
    @url = url
  end

  def extract
    uri = URI.parse(@url)
    response = Net::HTTP.get_response(uri)

    raise "HTTP #{response.code}: Failed to fetch #{@url}" unless response.is_a?(Net::HTTPSuccess)

    doc = Nokogiri::HTML(response.body)

    text = extract_schema_recipe(doc)
    unless text
      strip_non_content!(doc)
      text = extract_main_content(doc) || doc.at('body')&.text
    end
    clean_text(text.to_s)
  end

  private

  def strip_non_content!(doc)
    doc.css('script, style, nav, footer, header, iframe, .ad, .ads, .advertisement, [role="navigation"]').remove
  end

  def extract_schema_recipe(doc)
    doc.css('script[type="application/ld+json"]').each do |script|
      json = begin
        JSON.parse(script.text)
      rescue StandardError
        next
      end
      recipe = find_recipe_in_json(json)
      return format_schema_recipe(recipe) if recipe
    end
    nil
  end

  def find_recipe_in_json(json) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    case json
    when Hash
      return json if json['@type']&.to_s&.include?('Recipe')

      json.each_value do |v|
        result = find_recipe_in_json(v)
        return result if result
      end
    when Array
      json.each do |item|
        result = find_recipe_in_json(item)
        return result if result
      end
    end
    nil
  end

  def format_schema_recipe(recipe)
    parts = format_basic_fields(recipe)
    parts.concat(format_ingredients(recipe))
    parts.concat(format_instructions(recipe))
    parts.join("\n")
  end

  def format_basic_fields(recipe)
    SCHEMA_FIELDS.filter_map do |field|
      "#{SCHEMA_LABELS[field]}: #{recipe[field]}" if recipe[field]
    end
  end

  def format_ingredients(recipe)
    return [] unless recipe['recipeIngredient']

    ['Ingredients:'] + Array(recipe['recipeIngredient']).map { |i| "- #{i}" }
  end

  def format_instructions(recipe)
    return [] unless recipe['recipeInstructions']

    ['Instructions:'] + Array(recipe['recipeInstructions']).map.with_index(1) do |step, idx|
      text = step.is_a?(Hash) ? step['text'] : step.to_s
      "#{idx}. #{text}"
    end
  end

  def extract_main_content(doc)
    MAIN_CONTENT_SELECTORS.each do |sel|
      element = doc.at(sel)
      return element.text if element
    end
    nil
  end

  def clean_text(text)
    text.gsub(/[\t ]+/, ' ')
        .gsub(/\n{3,}/, "\n\n")
        .strip
        .truncate(MAX_TEXT_LENGTH)
  end
end
