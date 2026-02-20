require 'spec_helper'

# rubocop:disable RSpec/VerifiedDoubles
describe RecipeAiExtractor do
  describe '.extract' do
    let(:text) { 'A recipe for chocolate cake with flour and sugar' }
    let(:json_response) do
      {
        'name' => 'Chocolate Cake',
        'directions' => '1. Mix ingredients',
        'ingredients' => [{ 'quantity' => '2', 'unit' => 'cups', 'name' => 'flour', 'descriptor' => 'sifted' }]
      }
    end

    before do
      ENV['ANTHROPIC_API_KEY'] = 'test-key'
    end

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
end
# rubocop:enable RSpec/VerifiedDoubles
