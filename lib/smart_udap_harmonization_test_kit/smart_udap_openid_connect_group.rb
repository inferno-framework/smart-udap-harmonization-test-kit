require 'smart_app_launch/openid_connect_group'

module SMART_UDAP_HarmonizationTestKit
  class SMART_UDAP_OpenIDConnectGroup < SMARTAppLaunch::OpenIDConnectGroup
    id :smart_udap_openid_connect
    title 'Support for OpenID Connect'
    description <<~DESCRIPTION
      This group verifies support for OpenID Connect.
    DESCRIPTION

    run_as_group

    config(
      inputs: {
        client_id: {
          name: :udap_client_id,
          title: 'UDAP Client ID'
        },
        token_response_body: {
          name: :udap_auth_code_flow_token_exchange_response_body
        },
        requested_scopes: {
          name: :udap_auth_code_flow_registration_scope,
          title: 'Requested Scopes',
          description: 'Scopes client requested from the authorization server during the authorization step.'
        },
        url: {
          name: :udap_fhir_base_url,
          title: 'FHIR Server URL'
        }
      }
    )

    test do
      id :smart_udap_openid_connect_setup
      title 'OpenID Connect Test Setup'

      input :token_response_body,
            title: 'Token Exchange Response Body',
            description: 'JSON response body returned by the authorization server during the token exchange step'

      input :udap_auth_code_flow_token_retrieval_time,
            title: 'Token Retrieval Time'

      output :id_token,
             :access_token,
             :smart_credentials

      run do
        assert_valid_json(token_response_body)

        token_response = JSON.parse(token_response_body)

        output id_token: token_response['id_token'],
               access_token: token_response['access_token'],
               smart_credentials: {
                 access_token: token_response_body['access_token'],
                 expires_in: token_response_body['expires_in'],
                 udap_auth_code_flow_token_retrieval_time:
               }.to_json
      end
    end

    children.unshift children.pop
  end
end
