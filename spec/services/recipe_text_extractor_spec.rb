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

  describe 'AiClassifierRun recording' do
    let(:html) { '<html><body><article><p>Some recipe text</p></article></body></html>' }

    before { stub_request(:get, url).to_return(status: 200, body: html) }

    it 'creates a run with service_class RecipeTextExtractor' do
      expect { described_class.from_url(url) }.to change(AiClassifierRun, :count).by(1)

      run = AiClassifierRun.last
      expect(run.service_class).to eq('RecipeTextExtractor')
      expect(run.user_prompt).to eq(url)
      expect(run.adapter).to be_nil
      expect(run.ai_model).to be_nil
    end

    it 'records a successful run with raw_response and completed_at' do
      described_class.from_url(url)

      run = AiClassifierRun.last
      expect(run.success).to be true
      expect(run.raw_response).to include('Some recipe text')
      expect(run.started_at).not_to be_nil
      expect(run.completed_at).not_to be_nil
    end

    it 'associates the run with the provided recipe' do
      recipe = create(:recipe)
      described_class.from_url(url, recipe: recipe)

      expect(AiClassifierRun.includes(:recipe).last.recipe).to eq(recipe)
    end

    context 'when an HTTP error occurs' do
      before { stub_request(:get, url).to_return(status: 404) }

      it 'records a failed run and re-raises' do
        expect { described_class.from_url(url) }.to raise_error(/HTTP 404/)

        run = AiClassifierRun.last
        expect(run.success).to be false
        expect(run.error_class).to be_present
        expect(run.error_message).to include('404')
        expect(run.completed_at).not_to be_nil
      end
    end
  end
end
