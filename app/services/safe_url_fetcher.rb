require 'ipaddr'
require 'net/http'
require 'uri'

class SafeUrlFetcher
  class BlockedAddressError < StandardError; end

  # Subclasses BlockedAddressError so existing rescuers keep working, while
  # callers that care can tell "response too big" from "internal address".
  class ResponseTooLargeError < BlockedAddressError; end
  class TooManyRedirectsError < StandardError; end
  class RedirectWithoutLocationError < StandardError; end

  # Accumulates a response body while enforcing the cap *during* the read, so a
  # hostile server can't force the whole payload into memory before we check.
  # Subclasses String so Net::HTTPResponse#body still hands callers a String
  # (RecipeTextExtractor passes it straight to Nokogiri).
  class SizeLimitedBody < String
    def initialize(limit)
      super()
      @limit = limit
    end

    def <<(chunk)
      if bytesize + chunk.bytesize > @limit
        raise ResponseTooLargeError, "Response exceeds maximum size of #{@limit} bytes"
      end

      super
    end
  end

  MAX_REDIRECTS = 5
  MAX_BYTES     = 5.megabytes
  OPEN_TIMEOUT  = 5
  READ_TIMEOUT  = 15

  # All addresses in these ranges resolve to internal, non-public networks.
  # Blocking them prevents server-side request forgery (SSRF) against
  # loopback, private, cloud metadata, link-local, and ULA endpoints while
  # leaving public recipe sites (public IPs) fully fetchable.
  BLOCKED_NETWORKS = [
    IPAddr.new('0.0.0.0/8'),
    IPAddr.new('10.0.0.0/8'),
    IPAddr.new('100.64.0.0/10'),      # CGNAT
    IPAddr.new('127.0.0.0/8'),        # loopback
    IPAddr.new('169.254.0.0/16'),     # link-local incl. AWS metadata 169.254.169.254
    IPAddr.new('172.16.0.0/12'),
    IPAddr.new('192.168.0.0/16'),
    IPAddr.new('::1'),
    IPAddr.new('fc00::/7'),           # IPv6 unique-local
    IPAddr.new('fe80::/10')           # IPv6 link-local
  ].freeze

  def self.fetch(url, max_redirects: MAX_REDIRECTS)
    new(url, max_redirects: max_redirects).fetch
  end

  # Resolves a host to its IP addresses. Extracted as its own class method so
  # specs can stub it without touching real DNS (WebMock stubs Net::HTTP, not
  # the socket resolver we use for SSRF validation).
  def self.addresses_for(host)
    Addrinfo.getaddrinfo(host, nil, nil, :STREAM).map(&:ip_address).uniq
  rescue SocketError
    raise ArgumentError, "Unable to resolve host: #{host}"
  end

  def self.blocked_address?(ip)
    ip = IPAddr.new(ip.to_s)
    ip = ip.native if ip.ipv4_mapped?

    BLOCKED_NETWORKS.any? { |range| range.include?(ip) }
  end

  def initialize(url, max_redirects: MAX_REDIRECTS)
    @uri = URI.parse(url)
    @max_redirects = max_redirects
  end

  def fetch
    validate_uri!(reachable_uri)
    validate_destination!(reachable_uri)

    uri = reachable_uri
    redirects = 0

    loop do
      response = http_get(uri)
      return response unless redirect?(response)

      raise TooManyRedirectsError, "Too many redirects fetching #{@uri}" if redirects >= @max_redirects

      location = response['location']
      raise RedirectWithoutLocationError, "Redirect without location from #{uri}" if location.blank?

      uri = URI.join(uri, location)
      validate_uri!(uri)
      validate_destination!(uri)
      redirects += 1
    end
  end

  private

  def reachable_uri
    @reachable_uri ||= URI.parse(@uri.to_s)
  end

  def validate_uri!(uri)
    raise ArgumentError, 'Invalid URL' unless uri.is_a?(URI::HTTP)
    raise ArgumentError, 'Missing host' if uri.host.blank?
  end

  def validate_destination!(uri)
    self.class.addresses_for(uri.host).each do |ip|
      next unless self.class.blocked_address?(ip)

      raise BlockedAddressError,
            "Refusing to fetch #{uri} because it resolves to internal address #{ip}"
    end
  end

  def http_get(uri)
    request = Net::HTTP::Get.new(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http.open_timeout = OPEN_TIMEOUT
    http.read_timeout = READ_TIMEOUT

    result = nil
    http.start do |connection|
      connection.request(request) do |response|
        reject_oversized_content_length!(response)

        # Every response is read through the capped buffer, redirects included:
        # Net::HTTP drains any body left unread when the block exits, which
        # would otherwise pull an unbounded redirect body into memory uncapped.
        response.read_body(SizeLimitedBody.new(MAX_BYTES))
        result = response
      end
    end
    result
  end

  # Cheap pre-check: refuse before reading a single byte when the server has
  # already told us the payload is too big.
  def reject_oversized_content_length!(response)
    return if response['content-length'].to_i <= MAX_BYTES

    raise ResponseTooLargeError, "Response exceeds maximum size of #{MAX_BYTES} bytes"
  end

  def redirect?(response)
    response.is_a?(Net::HTTPRedirection)
  end
end
