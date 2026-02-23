require 'spec_helper'

# rubocop:disable RSpec/VerifiedDoubles
describe RecipeAiExtractor do
  let(:text) { 'A recipe for chocolate cake with flour and sugar' }
  let(:json_response) do
    {
      'name' => 'Chocolate Cake',
      'directions' => '1. Mix ingredients',
      'ingredients' => [{ 'quantity' => '2', 'unit' => 'cups', 'name' => 'flour', 'descriptor' => 'sifted' }]
    }
  end

  def stub_ruby_llm(content:)
    mock_response = double('response', content: content)
    mock_chat     = double('chat', with_instructions: nil, ask: mock_response)
    allow(RubyLLM).to receive(:chat).and_return(mock_chat)
    mock_chat
  end

  describe '.extract' do
    before do
      ENV['ANTHROPIC_API_KEY'] = 'test-key'
    end

    it 'sends text to Claude API and returns parsed JSON' do
      mock_chat = stub_ruby_llm(content: json_response.to_json)

      result = described_class.extract(text)

      expect(result).to eq(json_response)
      expect(RubyLLM).to have_received(:chat).with(model: 'claude-haiku-4-5-20251001')
      expect(mock_chat).to have_received(:with_instructions).with(RecipeAiExtractor::SYSTEM_PROMPT)
      expect(mock_chat).to have_received(:ask).with(including(text))
    end

    it 'uses a custom model from ANTHROPIC_MODEL' do
      ENV['ANTHROPIC_MODEL'] = 'claude-sonnet-4-6'
      stub_ruby_llm(content: json_response.to_json)

      described_class.extract(text)

      expect(RubyLLM).to have_received(:chat).with(model: 'claude-sonnet-4-6')
    ensure
      ENV.delete('ANTHROPIC_MODEL')
    end

    it 'strips ```json fences from response' do
      stub_ruby_llm(content: "```json\n#{json_response.to_json}\n```")
      expect(described_class.extract(text)).to eq(json_response)
    end

    it 'strips bare ``` fences from response' do
      stub_ruby_llm(content: "```\n#{json_response.to_json}\n```")
      expect(described_class.extract(text)).to eq(json_response)
    end
  end

  describe 'AiClassifierRun recording' do
    before do
      ENV['ANTHROPIC_API_KEY'] = 'test-key'
    end

    context 'on success with anthropic adapter' do
      it 'creates a successful AiClassifierRun with correct metadata' do
        stub_ruby_llm(content: json_response.to_json)

        expect { described_class.extract(text) }.to change(AiClassifierRun, :count).by(1)

        run = AiClassifierRun.last
        expect(run.service_class).to eq('RecipeAiExtractor')
        expect(run.success).to be true
        expect(run.adapter).to eq('anthropic')
        expect(run.ai_model).to eq('claude-haiku-4-5-20251001')
        expect(run.system_prompt).to eq(RecipeAiExtractor::SYSTEM_PROMPT)
        expect(run.user_prompt).to include(text)
        expect(run.raw_response).to eq(json_response.to_json)
        expect(run.started_at).not_to be_nil
        expect(run.completed_at).not_to be_nil
        expect(run.error_class).to be_nil
        expect(run.error_message).to be_nil
      end

      it 'persists the run immediately (before LLM call completes)' do
        # The run should be saved with success: false before we get a response
        call_count = 0
        allow(AiClassifierRun).to receive(:create!).and_wrap_original do |orig, **attrs|
          call_count += 1
          expect(AiClassifierRun.count).to eq(call_count - 1) if call_count == 1
          orig.call(**attrs)
        end

        stub_ruby_llm(content: json_response.to_json)
        described_class.extract(text)
      end

      it 'associates the run with the provided recipe' do
        recipe = create(:recipe)
        stub_ruby_llm(content: json_response.to_json)

        described_class.extract(text, recipe: recipe)

        expect(AiClassifierRun.includes(:recipe).last.recipe).to eq(recipe)
      end
    end

    context 'on failure with anthropic adapter' do
      it 'creates a failed AiClassifierRun and re-raises the error' do
        mock_chat = double('chat', with_instructions: nil)
        allow(mock_chat).to receive(:ask).and_raise(RuntimeError, 'connection refused')
        allow(RubyLLM).to receive(:chat).and_return(mock_chat)

        expect { described_class.extract(text) }.to raise_error(RuntimeError, 'connection refused')

        run = AiClassifierRun.last
        expect(run.service_class).to eq('RecipeAiExtractor')
        expect(run.success).to be false
        expect(run.error_class).to eq('RuntimeError')
        expect(run.error_message).to eq('connection refused')
        expect(run.raw_response).to be_nil
        expect(run.completed_at).not_to be_nil
      end
    end
  end
end
# rubocop:enable RSpec/VerifiedDoubles
