module SMART_UDAP_HarmonizationTestKit
  class AuthorizationCodeAuthenticationGroup < Inferno::TestGroup
    title 'UDAP Authorization Code Authorization & Authentication'
    description %(
      This group tests the use of the authorization_code grant type in conjunction with SMART scopes to receive an authorization code from the
      authorization server and exchange it for an access token, as described
      in the [consumer-facing](https://hl7.org/fhir/us/udap-security/STU1/consumer.html) and
      [business-to-business (B2B)](https://hl7.org/fhir/us/udap-security/STU1/b2b.html) profiles requirements.

      Additionally, it tests that the authorization server returns the proper information based on the scopes requested.
    )
    id :harmonization_authorization_code_authentication_group

    # TODO: consider breaking into 2 groups: baseline UDAP and scope assessment
    # TODO: redo test to include scopes
    test from: :udap_authorization_code_redirect
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

    # TODO: include test that checks for scope claim in token exchange response
    # body
    
    test from: :udap_token_exchange_response_headers,
         config: {
           requests: {
             token_exchange: {
               name: :authorization_code_token_exchange
             }
           }
         }

    # TODO: include tests (import or reuse logic from SMART App Launch) that
    # will conditionally assess ID token and use of refresh token, depending on
    # requested scopes
  end
end