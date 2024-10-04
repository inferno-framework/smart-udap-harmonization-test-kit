require 'smart_app_launch/openid_connect_group'

module SMART_UDAP_HarmonizationTestKit
  class SMART_UDAP_OpenIDConnectGroup < SMARTAppLaunch::OpenIDConnectGroup
    id :smart_udap_openid_connect
    title 'Support for OpenID Connect'
    description <<~DESCRIPTION
      This group verifies support for OpenID Connect.
    DESCRIPTION

    config(
      inputs: {
        client_id: {
          name: :udap_client_id
        },
        requested_scopes: {
          name: :udap_registration_scope_auth_code_flow
        },
        url: {
          name: :udap_fhir_base_url
        }
      }
    )

    test do
      id :smart_udap_openid_connect_setup
      title 'OpenID Connect Test Setup'

      input :token_response_body
      input :token_retrieval_time
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
                 token_retrieval_time:
               }.to_json
      end
    end

    children.unshift children.pop
  end
end
