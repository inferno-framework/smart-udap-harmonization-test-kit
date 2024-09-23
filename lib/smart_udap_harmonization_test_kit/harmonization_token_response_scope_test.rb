require 'smart_app_launch/token_payload_validation'

module SMART_UDAP_HarmonizationTestKit
  class HarmonizationTokenResponseScopeTest < Inferno::Test
    include SMARTAppLaunch::TokenPayloadValidation
    title 'Token exchange reponse body includes required content for SMART scopes'
    id :harmonization_token_response_scope
    description %(
        In addition to the baseline UDAP requirements for the token exchange response body, this test verifies that the scope parameter is included in the response body and issues a warning if any of the requested scopes are missing.
      )

    input :token_response_body
    input :udap_registration_requested_scope

    # TODO: do any of these not apply in a UDAP context?
    output :id_token,
           :refresh_token,
           :access_token,
           :expires_in,
           :patient_id,
           :encounter_id,
           :received_scopes,
           :intent

    run do
      token_response_body_parsed = JSON.parse(token_response_body)
      output id_token: token_response_body_parsed['id_token'],
             refresh_token: token_response_body_parsed['refresh_token'],
             access_token: token_response_body_parsed['access_token'],
             expires_in: token_response_body_parsed['expires_in'],
             patient_id: token_response_body_parsed['patient'],
             encounter_id: token_response_body_parsed['encounter'],
             received_scopes: token_response_body_parsed['scope'],
             intent: token_response_body_parsed['intent']

      assert received_scopes.present?, 'Token exchange response does not include the `scope` parameter'

      check_for_missing_scopes(udap_registration_requested_scope, token_response_body_parsed)
    end
  end
end