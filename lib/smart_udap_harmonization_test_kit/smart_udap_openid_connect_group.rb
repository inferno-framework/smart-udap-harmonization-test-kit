require 'smart_app_launch/openid_connect_group'

module SMART_UDAP_HarmonizationTestKit
  class SMART_UDAP_OpenIDConnectGroup < SMARTAppLaunch::OpenIDConnectGroup # rubocop:disable Naming/ClassAndModuleCamelCase
    id :smart_udap_openid_connect
    title 'Support for OpenID Connect'
    description <<~DESCRIPTION
      This group verifies support for OpenID Connect.
    DESCRIPTION

    run_as_group

    config(
      inputs: {
        smart_auth_info: {
          title: 'UDAP Auth Info',
          options: {
            mode: 'access',
            components: [
              {
                name: :auth_type,
                default: 'asymmetric',
                locked: true
              },
              {
                name: :kid, # to be hidden
                locked: true
              },
              {
                name: :jwks, # to be hidden
                locked: true
              },
              {
                name: :requested_scopes # additional component to display
              }
            ]
          }
        },
        token_response_body: {
          name: :udap_auth_code_flow_token_exchange_response_body
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

      # Needed to tranfer it to smart_auth_info. Should probably be hidden here
      input :udap_auth_code_flow_registration_scope

      input :smart_auth_info, type: :auth_info

      output :id_token,
             :access_token,
             :smart_credentials,
             :smart_auth_info

      run do
        assert_valid_json(token_response_body)

        token_response = JSON.parse(token_response_body)

        smart_auth_info.access_token = token_response['access_token']
        smart_auth_info.expires_in = token_response['expires_in']
        smart_auth_info.requested_scopes = udap_auth_code_flow_registration_scope

        output id_token: token_response['id_token'],
               access_token: token_response['access_token'],
               smart_credentials: smart_auth_info,
               smart_auth_info: smart_auth_info
      end
    end

    children.unshift children.pop
  end
end
