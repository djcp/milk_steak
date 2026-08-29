require 'spec_helper'

describe SafeUrlFetcher do
  describe '.blocked_address?' do
    it 'blocks IPv4 private ranges' do
      expect(described_class.blocked_address?('10.0.0.1')).to be true
      expect(described_class.blocked_address?('172.16.0.1')).to be true
      expect(described_class.blocked_address?('172.31.255.255')).to be true
      expect(described_class.blocked_address?('192.168.1.1')).to be true
    end

    it 'blocks loopback and CGNAT ranges' do
      expect(described_class.blocked_address?('127.0.0.1')).to be true
      expect(described_class.blocked_address?('100.64.0.1')).to be true
    end

    it 'blocks link-local and the AWS metadata endpoint' do
      expect(described_class.blocked_address?('169.254.169.254')).to be true
      expect(described_class.blocked_address?('169.254.0.1')).to be true
    end

    it 'blocks IPv6 loopback, ULA, and link-local addresses' do
      expect(described_class.blocked_address?('::1')).to be true
      expect(described_class.blocked_address?('fc00::1')).to be true
      expect(described_class.blocked_address?('fd12:3456::1')).to be true
      expect(described_class.blocked_address?('fe80::1')).to be true
    end

    it 'blocks IPv4-mapped IPv6 addresses by their underlying IPv4' do
      expect(described_class.blocked_address?('::ffff:127.0.0.1')).to be true
      expect(described_class.blocked_address?('::ffff:10.0.0.5')).to be true
    end

    it 'allows public IP addresses' do
      expect(described_class.blocked_address?('93.184.216.34')).to be false
      expect(described_class.blocked_address?('8.8.8.8')).to be false
      expect(described_class.blocked_address?('2606:4700::6810:84e5')).to be false
    end
  end

  describe '.fetch' do
    let(:url) { 'https://recipes.example.com/cake' }

    before { allow(described_class).to receive(:addresses_for).and_return(['93.184.216.34']) }

    it 'returns the response body on success' do
      body = '<html><body>recipe</body></html>'
      stub_request(:get, url).to_return(status: 200, body: body)

      response = described_class.fetch(url)

      expect(response).to be_a(Net::HTTPResponse)
      expect(response.body).to eq(body)
    end

    it 'raises BlockedAddressError when the host resolves to an internal address' do
      allow(described_class).to receive(:addresses_for).with('internal.example.com').and_return(['10.0.0.1'])
      stub_request(:get, 'https://internal.example.com/cake')

      expect { described_class.fetch('https://internal.example.com/cake') }
        .to raise_error(described_class::BlockedAddressError, /internal address 10\.0\.0\.1/)
    end

    it 'raises BlockedAddressError when a redirect resolves to an internal address' do
      allow(described_class).to receive(:addresses_for) do |host|
        host == 'recipes.example.com' ? ['93.184.216.34'] : ['169.254.169.254']
      end
      stub_request(:get, url).to_return(
        status: 302,
        headers: { 'Location' => 'https://169.254.169.254/latest/meta-data' }
      )

      expect { described_class.fetch(url) }.to raise_error(described_class::BlockedAddressError, /169\.254\.169\.254/)
    end

    it 'raises when the response exceeds the maximum size' do
      stub_const('SafeUrlFetcher::MAX_BYTES', 100)
      stub_request(:get, url).to_return(status: 200, body: 'x' * 101)

      expect { described_class.fetch(url) }.to raise_error(described_class::BlockedAddressError, /exceeds maximum size/)
    end

    it 'raises for non-http(s) schemes' do
      expect { described_class.fetch('file:///etc/passwd') }.to raise_error(ArgumentError)
    end

    it 'raises for a missing host' do
      expect { described_class.fetch('https:///path') }.to raise_error(ArgumentError, /Missing host/)
    end
  end
end
