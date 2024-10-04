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
        }
      }
    )

    test do
      id :smart_udap_openid_connect_setup
      title 'OpenID Connect Test Setup'

      input :token_response_body
      input :udap_software_statement_json
      input :token_retrieval_time
      output :id_token,
             :requested_scopes,
             :access_token,
             :smart_credentials

      run do
        assert_valid_json(token_response_body)

        token_response = JSON.parse(token_response_body)

        assert_valid_json(udap_software_statement_json)

        udap_software_statement = JSON.parse(udap_software_statement_json)

        output id_token: token_response['id_token'],
               requested_scopes: udap_software_statement['scope'],
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
