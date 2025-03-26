require 'smart_app_launch/token_payload_validation'

module SMART_UDAP_HarmonizationTestKit
  class SMART_UDAP_TokenResponseScopeTest < Inferno::Test # rubocop:disable Naming/ClassAndModuleCamelCase
    include SMARTAppLaunch::TokenPayloadValidation
    title 'Token exchange reponse body includes required content for SMART scopes'
    id :smart_udap_token_response_scope
    description %(
        In addition to the baseline UDAP requirements for the token exchange response body, this test verifies that the
        scope parameter is included in the response body and issues a warning if any of the requested scopes are
        missing.
      )

    input :udap_auth_code_flow_token_exchange_response_body,
          :udap_authorization_code_request_scopes,
          :udap_auth_code_flow_token_retrieval_time,
          :udap_token_endpoint,
          :udap_client_id

    input :udap_auth_code_flow_registration_scope,
          title: 'Authorization Code Registration Requested Scope(s)',
          description: %(
            String containing a space delimited list of scopes requested by the client application for use in
            subsequent requests. The Authorization Server MAY consider this list when deciding the scopes that it
            will allow the application to subsequently request. Apps requesting the "authorization_code" grant
            type SHOULD request user or patient scopes.
          )

    output :id_token,
           :refresh_token,
           :access_token,
           :expires_in,
           :patient_id,
           :encounter_id,
           :received_scopes,
           :smart_auth_info

    run do
      assert_valid_json(udap_auth_code_flow_token_exchange_response_body)
      token_response_body_parsed = JSON.parse(udap_auth_code_flow_token_exchange_response_body)

      smart_auth_info = Inferno::DSL::AuthInfo.new(
        {
          refresh_token: token_response_body_parsed['refresh_token'],
          access_token: token_response_body_parsed['access_token'],
          expires_in: token_response_body_parsed['expires_in'],
          client_id: udap_client_id,
          issue_time: udap_auth_code_flow_token_retrieval_time,
          requested_scopes: udap_auth_code_flow_registration_scope,
          token_url: udap_token_endpoint
        }
      )

      output id_token: token_response_body_parsed['id_token'],
             refresh_token: token_response_body_parsed['refresh_token'],
             access_token: token_response_body_parsed['access_token'],
             expires_in: token_response_body_parsed['expires_in'],
             patient_id: token_response_body_parsed['patient'],
             encounter_id: token_response_body_parsed['encounter'],
             received_scopes: token_response_body_parsed['scope'],
             smart_auth_info: smart_auth_info

      assert received_scopes.present?, 'Token exchange response does not include the `scope` parameter'

      check_for_missing_scopes(udap_authorization_code_request_scopes, token_response_body_parsed)
    end
  end
end
