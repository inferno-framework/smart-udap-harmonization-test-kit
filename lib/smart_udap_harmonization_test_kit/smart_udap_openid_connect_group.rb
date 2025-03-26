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
            mode: 'access'
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
  end
end
