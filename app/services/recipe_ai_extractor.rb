class RecipeAiExtractor
  SYSTEM_PROMPT = <<~PROMPT.freeze
    You are a recipe extraction assistant. Given text from a recipe website or user input,
    extract the structured recipe data and return it as valid JSON.

    Return ONLY a JSON object with these fields, and make sure the values are properly escaped and only contain JSON safe characters:
    {
      "name": "Recipe name",
      "description": "Brief description (1-2 sentences)",
      "directions": "Clear, numbered cooking steps in markdown. Remove narrative fluff, ads, life stories. Keep only actionable cooking instructions.",
      "preparation_time": null or integer (minutes),
      "cooking_time": null or integer (minutes),
      "servings": null or integer,
      "serving_units": "e.g. servings, cups, pieces" or null,
      "ingredients": [
        {"quantity": "1", "unit": "cup", "name": "flour", "section": "Crust"}
      ],
      "cooking_methods": ["bake", "saute"],
      "cultural_influences": ["italian"],
      "courses": ["dinner", "entree"],
      "dietary_restrictions": ["vegetarian"]
    }

    Rules:
    - Ingredient names should be lowercase and simple, strip specific brand names when possible
    - Quantity should be a string that can include fractions like "1/2"
    - Tags (cooking_methods, cultural_influences, courses, dietary_restrictions) should be lowercase
    - Only include dietary_restrictions that actually apply
    - Directions should be clear numbered steps, no life stories or filler text
    - If a recipe has distinct ingredient groups (e.g. "Crust", "Filling", "Sauce", "Dressing"), set the "section" field to the group name for each ingredient. Use null for ingredients that don't belong to a named section. Only use sections when the recipe clearly organizes ingredients into groups.
    - Return ONLY valid JSON, no JSON markdown code fences, no explanation
  PROMPT

  def self.extract(text)
    new(text).extract
  end

  def initialize(text)
    @text = text
  end

  def extract
    client = Anthropic::Client.new(api_key: ENV.fetch('ANTHROPIC_API_KEY'))

    response = client.messages.create(
      model: 'claude-sonnet-4-5-20250929',
      max_tokens: 4096,
      system: SYSTEM_PROMPT,
      messages: [
        { role: 'user', content: "Extract the recipe from this text:\n\n#{@text}" }
      ]
    )

    json_text = response.content.first.text
    JSON.parse(normalize_json(json_text))
  end

  private

  def normalize_json(text)
    text = text.strip
    text = text.gsub(/\A```(?:json)?\s*\n?/, '').gsub(/\n?\s*```\z/, '')
    text.strip
  end
end
