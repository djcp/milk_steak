require 'spec_helper'

describe RecipeTextExtractor do
  let(:url) { 'https://example.com/recipe' }

  describe '.from_url' do
    it 'extracts text from a recipe page' do
      html = <<~HTML
        <html>
        <head><title>Recipe</title></head>
        <body>
          <nav>Navigation</nav>
          <article>
            <h1>Chocolate Cake</h1>
            <p>Mix flour and sugar. Bake at 350F.</p>
          </article>
          <footer>Footer</footer>
        </body>
        </html>
      HTML

      stub_request(:get, url).to_return(status: 200, body: html)

      result = described_class.from_url(url)

      expect(result).to include('Chocolate Cake')
      expect(result).to include('Mix flour and sugar')
      expect(result).not_to include('Navigation')
      expect(result).not_to include('Footer')
    end

    it 'extracts schema.org Recipe data when available' do
      html = <<~HTML
        <html>
        <head>
          <script type="application/ld+json">
          {
            "@type": "Recipe",
            "name": "Test Recipe",
            "recipeIngredient": ["1 cup flour", "2 eggs"],
            "recipeInstructions": [{"text": "Mix well"}, {"text": "Bake"}]
          }
          </script>
        </head>
        <body><p>Some content</p></body>
        </html>
      HTML

      stub_request(:get, url).to_return(status: 200, body: html)

      result = described_class.from_url(url)

      expect(result).to include('Test Recipe')
      expect(result).to include('1 cup flour')
      expect(result).to include('Mix well')
    end

    it 'truncates text to MAX_TEXT_LENGTH' do
      long_content = 'x' * 20_000
      html = "<html><body><article>#{long_content}</article></body></html>"
      stub_request(:get, url).to_return(status: 200, body: html)

      result = described_class.from_url(url)

      expect(result.length).to be <= RecipeTextExtractor::MAX_TEXT_LENGTH
    end

    it 'raises on HTTP errors' do
      stub_request(:get, url).to_return(status: 404)

      expect do
        described_class.from_url(url)
      end.to raise_error(/HTTP 404/)
    end
  end
end
