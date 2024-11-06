require_relative 'smart_udap_token_refresh_test'
require_relative 'smart_udap_token_refresh_with_scopes_group'
require 'udap_security_test_kit/token_exchange_response_body_test'
require 'udap_security_test_kit/token_exchange_response_headers_test'

module SMART_UDAP_HarmonizationTestKit
  class SMART_UDAP_TokenRefreshWithoutScopesGroup < Inferno::TestGroup
    title 'Support for Token Refresh Without Scopes'
    id :smart_udap_token_refresh_without_scopes

    scopes_omitted_description = %(
      The optional `scope` parameter will not be inclued in the token exchange request. [RFC 6749 Section 6](https://datatracker.ietf.org/doc/html/rfc6749#section-6)
      states:
      > The requested scope MUST NOT include any scope
        not originally granted by the resource owner, and *if omitted is
        treated as equal to the scope originally granted by the
        resource owner*.
    )

    description %(
      #{SMART_UDAP_HarmonizationTestKit::SMART_UDAP_TokenRefreshWithScopesGroup.token_refresh_group_description}
      #{scopes_omitted_description}
    )

    test from: :smart_udap_token_refresh

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
