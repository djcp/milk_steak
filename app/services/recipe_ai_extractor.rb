class RecipeAiExtractor
  SYSTEM_PROMPT = <<~PROMPT.freeze
    You are a recipe extraction assistant. Given text from a recipe website or user input,
    extract the structured recipe data and return it as valid JSON.

    Return ONLY a JSON object with these fields, and make sure the values are properly escaped and only contain JSON safe characters:
    {
      "name": "Recipe name",
      "description": "Brief description (1-2 sentences)",
      "directions": "Clear, numbered cooking steps in markdown.",
      "preparation_time": null or integer (minutes, prep only — chopping, measuring, marinating),
      "cooking_time": null or integer (minutes, total time on heat including baking, simmering, resting),
      "servings": null or integer,
      "serving_units": "e.g. servings, cups, pieces" or null,
      "ingredients": [
        {"quantity": "1", "unit": "cup", "name": "flour", "descriptor": "sifted", "section": "Crust"}
      ],
      "cooking_methods": ["bake", "saute"],
      "cultural_influences": ["italian"],
      "courses": ["dinner", "entree"],
      "dietary_restrictions": ["vegetarian"]
    }

    Ingredients:
    - Names should be the plain canonical ingredient only, lowercase (e.g. "onion", "garlic", "tomato"). No prep verbs, no quality adjectives, strip specific brand names
    - Put any preparation method or quality descriptor in the separate `descriptor` field, lowercase (e.g. "diced", "minced", "ripe", "fresh", "crushed"). Omit the field (or use null) if there is no descriptor
    - Quantity should be a string that can include fractions like "1/2". Use "to taste" when no specific amount is given
    - Unit should be a standard measurement (cup, tbsp, tsp, oz, lb, etc.) or empty string when not applicable (e.g. "2" "large" "eggs")
    - Every ingredient in the list MUST be referenced in the directions. If the source text mentions an ingredient only in the directions but not in the ingredient list, add it to the ingredients list

    Sections:
    - If a recipe has distinct ingredient groups (e.g. "Crust", "Filling", "Sauce", "Dressing", "Spice Mixture"), set the "section" field for each ingredient in that group
    - Use short, title-cased section names (e.g. "Crust" not "For the crust")
    - Use null for ingredients that don't belong to a named section
    - Only use sections when the recipe clearly organizes ingredients into groups

    Description:
    - 1-2 sentences describing the dish itself — what it is and what makes it good
    - Do NOT include personal stories, anecdotes, recipe origin stories, or blog filler
    - Do NOT include tips, variations, serving suggestions, or storage instructions

    Directions:
    - Clear numbered steps — ONLY actionable cooking instructions
    - Strip out completely: life stories, personal anecdotes, blog filler, ads, "notes" sections, variation suggestions ("you could also use..."), storage/reheating tips, and serving suggestions
    - Reference ingredients by the same name used in the ingredients list for consistency
    - When sections exist, the directions should reference which component is being prepared (e.g. "For the crust, combine...")
    - Combine trivially small sub-steps into single steps where it makes sense

    Tags:
    - cooking_methods, cultural_influences, courses, dietary_restrictions should all be lowercase
    - Only include dietary_restrictions that actually apply

    Return ONLY valid JSON, no JSON markdown code fences, no explanation.
  PROMPT

  def self.extract(text)
    new(text).extract
  end

  def initialize(text)
    @text = text
  end

  def extract
    json_text = adapter.complete(SYSTEM_PROMPT, user_message)
    JSON.parse(normalize_json(json_text))
  end

  private

  def user_message
    "Extract the recipe from this text:\n\n#{@text}"
  end

  def adapter
    case ENV.fetch('RECIPE_AI_ADAPTER', 'anthropic')
    when 'ollama' then OllamaAdapter.new
    else               AnthropicAdapter.new
    end
  end

  def normalize_json(text)
    text = text.strip
    text = text.gsub(/\A```(?:json)?\s*\n?/, '').gsub(/\n?\s*```\z/, '')
    text.strip
  end

  # ---------------------------------------------------------------------------

  class AnthropicAdapter
    def complete(system_prompt, user_message)
      client = Anthropic::Client.new(api_key: ENV.fetch('ANTHROPIC_API_KEY'))
      response = client.messages.create(
        model: 'claude-sonnet-4-5-20250929',
        max_tokens: 4096,
        system: system_prompt,
        messages: [{ role: 'user', content: user_message }]
      )
      response.content.first.text
    end
  end

  # ---------------------------------------------------------------------------

  class OllamaAdapter
    def complete(system_prompt, user_message)
      uri = URI("#{base_url}/api/chat")
      body = {
        model: model,
        stream: false,
        messages: [
          { role: 'system', content: system_prompt },
          { role: 'user',   content: user_message }
        ]
      }.to_json

      req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      req.body = body

      res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
      raise "Ollama request failed (#{res.code}): #{res.body}" unless res.is_a?(Net::HTTPSuccess)

      JSON.parse(res.body).dig('message', 'content')
    end

    private

    def base_url
      ENV.fetch('OLLAMA_URL', 'http://localhost:11434')
    end

    def model
      ENV.fetch('OLLAMA_MODEL', 'llama3.2')
    end
  end
end
