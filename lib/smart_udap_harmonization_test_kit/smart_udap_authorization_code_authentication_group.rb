require_relative 'smart_udap_authorization_code_redirect_test'
require_relative 'smart_udap_token_response_scope_test'

module SMART_UDAP_HarmonizationTestKit
  class SMART_UDAP_AuthorizationCodeAuthenticationGroup < Inferno::TestGroup
    title 'UDAP Authorization Code Authorization & Authentication'
    description %(
      This group tests the use of the authorization_code grant type in conjunction with SMART scopes to receive an
      authorization code from the authorization server and exchange it for an access token, as described
      in the [consumer-facing](https://hl7.org/fhir/us/udap-security/STU1/consumer.html) and
      [business-to-business (B2B)](https://hl7.org/fhir/us/udap-security/STU1/b2b.html) profiles requirements.

      Additionally, it tests that the authorization server returns the proper information based on the scopes requested.
    )
    id :smart_udap_authorization_code_authentication_group

    # run_as_group

    test from: :smart_udap_authorization_code_redirect
    test from: :udap_authorization_code_received
    test from: :udap_authorization_code_token_exchange,
         config: {
           requests: {
             token_exchange: {
               name: :authorization_code_token_exchange
             }
           }
         }
    test from: :udap_token_exchange_response_body,
         config: {
           inputs: {
             token_response_body: {
               name: :authorization_code_token_response_body
             }
           }
         }

    test from: :smart_udap_token_response_scope,
         config: {
           inputs: {
             token_response_body: {
               name: :authorization_code_token_response_body
             },
             udap_registration_requested_scope: {
               name: :udap_registration_scope_auth_code_flow
             }
           }
         }

    test from: :udap_token_exchange_response_headers,
         config: {
           requests: {
             token_exchange: {
               name: :authorization_code_token_exchange
             }
           }
         }
  end
end
