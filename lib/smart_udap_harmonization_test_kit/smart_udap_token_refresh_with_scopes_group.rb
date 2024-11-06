require_relative 'smart_udap_token_refresh_test'
require 'udap_security_test_kit/token_exchange_response_body_test'
require 'udap_security_test_kit/token_exchange_response_headers_test'

module SMART_UDAP_HarmonizationTestKit
  class SMART_UDAP_TokenRefreshWithScopesGroup < Inferno::TestGroup
    title 'Support for Token Refresh With Scopes'
    id :smart_udap_token_refresh_with_scopes

    def self.token_refresh_group_description
      %(
      This group tests the ability of the system to successfully
      exchange a refresh token for an access token. Refresh tokens are typically
      longer lived than access tokens and allow client applications to obtain a
      new access token Refresh tokens themselves cannot provide access to
      resources on the server.

      Per the [HL7 UDAP STU1.0 IG Section on Refresh Tokens](https://hl7.org/fhir/us/udap-security/STU1/consumer.html#refresh-tokens)
      authorization server support for refresh tokens is optional:
      >This guide supports the use of refresh tokens, as described in [Section 1.5 of RFC 6749](https://datatracker.ietf.org/doc/html/rfc6749#section-1.5).
      >Authorization Servers **MAY** issue refresh tokens to consumer-facing client applications as per
      >[Section 5 of RFC 6749](https://datatracker.ietf.org/doc/html/rfc6749#section-5).
      >Client apps that have been issued refresh tokens **MAY** make refresh requests to the token endpoint as per
      >[Section 6 of RFC 6749](https://datatracker.ietf.org/doc/html/rfc6749#section-6).

      These tests will execute if the authorization server granted a refresh token during the authorization and
      authentication tests. They will attempt to exchange the refresh token for a new access token via a POST request
      to the token exchange endpoint and then verify the information returned as done in Section 1.3 tests 4-6.
    )
    end

    scopes_included_description = %(
      All the details about including scopes presented here!
    )

    description %(
      #{token_refresh_group_description}
      #{scopes_included_description}
    )

    test from: :smart_udap_token_refresh,
         config: {
           options: { include_scopes: true }
         }

    test from: :udap_token_exchange_response_body,
         config: {
           inputs: {
             token_response_body: {
               name: :smart_udap_token_refresh_response_body
             }
           }
         }

    test from: :udap_token_exchange_response_headers,
         config: {
           requests: {
             name: :smart_udap_token_refresh_request
           }
         }
  end
end
