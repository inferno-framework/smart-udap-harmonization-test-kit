require 'uri'

module SMART_UDAP_HarmonizationTestKit
  class SMART_UDAP_RequestBuilder
    # Client MUST authenticate to auth server during token refresh per RFC 6749
    # Section 6 https://datatracker.ietf.org/doc/html/rfc6749#section-6
    # Assuming auth mechanism is same as it was for token exchange, i.e.,
    # signed client assertion JWT
    def self.build_token_refresh_request(client_assertion_jwt, refresh_token, requested_scopes)
      token_refresh_headers = {
        'Accept' => 'application/json',
        'Content-Type' => 'application/x-www-form-urlencoded'
      }

      token_refresh_body = {
        'grant_type' => 'refresh_token',
        'refresh_token' => refresh_token,
        'scope' => requested_scopes,
        'client_assertion_type' => 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
        'client_assertion' => client_assertion_jwt,
        'udap' => '1'
      }.compact

      [token_refresh_headers, URI.encode_www_form(token_refresh_body)]
    end
  end
end
