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

  describe '.extract' do
    context 'with the anthropic adapter (default)' do
      before { ENV['ANTHROPIC_API_KEY'] = 'test-key' }

      after { ENV.delete('RECIPE_AI_ADAPTER') }

      it 'sends text to Claude API and returns parsed JSON' do
        mock_content = double('content', text: json_response.to_json)
        mock_response = double('response', content: [mock_content])
        mock_messages = double('messages')
        mock_client = double('client', messages: mock_messages)

        allow(Anthropic::Client).to receive(:new).and_return(mock_client)
        allow(mock_messages).to receive(:create).and_return(mock_response)

        result = described_class.extract(text)

        expect(result).to eq(json_response)
        expect(mock_messages).to have_received(:create).with(
          hash_including(
            model: 'claude-sonnet-4-5-20250929',
            messages: array_including(hash_including(role: 'user'))
          )
        )
      end

      it 'strips ```json fences from response' do
        wrapped = "```json\n#{json_response.to_json}\n```"
        mock_content = double('content', text: wrapped)
        mock_response = double('response', content: [mock_content])
        mock_messages = double('messages', create: mock_response)
        mock_client = double('client', messages: mock_messages)

        allow(Anthropic::Client).to receive(:new).and_return(mock_client)

        expect(described_class.extract(text)).to eq(json_response)
      end

      it 'strips bare ``` fences from response' do
        wrapped = "```\n#{json_response.to_json}\n```"
        mock_content = double('content', text: wrapped)
        mock_response = double('response', content: [mock_content])
        mock_messages = double('messages', create: mock_response)
        mock_client = double('client', messages: mock_messages)

        allow(Anthropic::Client).to receive(:new).and_return(mock_client)

        expect(described_class.extract(text)).to eq(json_response)
      end
    end

    context 'with the ollama adapter' do
      around do |example|
        ENV['RECIPE_AI_ADAPTER'] = 'ollama'
        ENV['OLLAMA_URL'] = 'http://localhost:11434'
        ENV['OLLAMA_MODEL'] = 'llama3.2'
        example.run
        ENV.delete('RECIPE_AI_ADAPTER')
        ENV.delete('OLLAMA_URL')
        ENV.delete('OLLAMA_MODEL')
      end

      let(:ollama_response) do
        { 'message' => { 'content' => json_response.to_json } }.to_json
      end

      it 'sends text to Ollama and returns parsed JSON' do
        stub_request(:post, 'http://localhost:11434/api/chat')
          .with(
            headers: { 'Content-Type' => 'application/json' },
            body: hash_including(
              'model' => 'llama3.2',
              'stream' => false,
              'messages' => array_including(hash_including('role' => 'system'))
            )
          )
          .to_return(status: 200, body: ollama_response, headers: { 'Content-Type' => 'application/json' })

        result = described_class.extract(text)

        expect(result).to eq(json_response)
      end

      it 'raises on non-200 response' do
        stub_request(:post, 'http://localhost:11434/api/chat')
          .to_return(status: 500, body: 'Internal Server Error')

        expect { described_class.extract(text) }.to raise_error(/Ollama request failed \(500\)/)
      end

      it 'uses a custom model from OLLAMA_MODEL' do
        ENV['OLLAMA_MODEL'] = 'mistral'

        stub_request(:post, 'http://localhost:11434/api/chat')
          .with(body: hash_including('model' => 'mistral'))
          .to_return(status: 200, body: ollama_response)

        described_class.extract(text)

        expect(a_request(:post, 'http://localhost:11434/api/chat')
          .with(body: hash_including('model' => 'mistral'))).to have_been_made
      end

      it 'uses a custom base URL from OLLAMA_URL' do
        ENV['OLLAMA_URL'] = 'http://my-server:11434'

        stub_request(:post, 'http://my-server:11434/api/chat')
          .to_return(status: 200, body: ollama_response)

        described_class.extract(text)

        expect(a_request(:post, 'http://my-server:11434/api/chat')).to have_been_made
      end
    end
  end
end
# rubocop:enable RSpec/VerifiedDoubles
