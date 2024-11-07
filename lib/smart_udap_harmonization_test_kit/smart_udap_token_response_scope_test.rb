require 'smart_app_launch/token_payload_validation'

module SMART_UDAP_HarmonizationTestKit
  class SMART_UDAP_TokenResponseScopeTest < Inferno::Test
    include SMARTAppLaunch::TokenPayloadValidation
    title 'Token exchange reponse body includes required content for SMART scopes'
    id :smart_udap_token_response_scope
    description %(
        In addition to the baseline UDAP requirements for the token exchange response body, this test verifies that the
        scope parameter is included in the response body and issues a warning if any of the requested scopes are
        missing.
      )

    input :token_response_body,
          :udap_auth_code_flow_registration_scope,
          :udap_auth_code_flow_token_retrieval_time,
          :udap_token_endpoint,
          :udap_client_id

    output :smart_credentials,
           :id_token,
           :refresh_token,
           :access_token,
           :expires_in,
           :patient_id,
           :encounter_id,
           :received_scopes

    run do
      assert_valid_json(token_response_body)
      token_response_body_parsed = JSON.parse(token_response_body)

      output smart_credentials: {
        refresh_token: token_response_body_parsed['refresh_token'],
        access_token: token_response_body_parsed['access_token'],
        expires_in: token_response_body_parsed['expires_in'],
        client_id: udap_client_id,
        client_secret: '',
        udap_auth_code_flow_token_retrieval_time:,
        token_url: udap_token_endpoint
      }.to_json

      output id_token: token_response_body_parsed['id_token'],
             refresh_token: token_response_body_parsed['refresh_token'],
             access_token: token_response_body_parsed['access_token'],
             expires_in: token_response_body_parsed['expires_in'],
             patient_id: token_response_body_parsed['patient'],
             encounter_id: token_response_body_parsed['encounter'],
             received_scopes: token_response_body_parsed['scope']

      assert received_scopes.present?, 'Token exchange response does not include the `scope` parameter'

      check_for_missing_scopes(udap_auth_code_flow_registration_scope, token_response_body_parsed)
    end
  end
end
