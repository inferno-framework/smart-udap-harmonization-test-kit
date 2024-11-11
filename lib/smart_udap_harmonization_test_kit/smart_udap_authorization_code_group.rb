require 'udap_security_test_kit/discovery_group'
require 'udap_security_test_kit/dynamic_client_registration_group'

require_relative 'smart_udap_authorization_code_authentication_group'
require_relative 'smart_udap_launch_context_group'
require_relative 'smart_udap_openid_connect_group'
require_relative 'smart_udap_token_refresh_with_scopes_group'
require_relative 'smart_udap_token_refresh_without_scopes_group'

module SMART_UDAP_HarmonizationTestKit # rubocop:disable Naming/ClassAndModuleCamelCase
  class SMART_UDAP_Authorization_Code_Group < Inferno::TestGroup # rubocop:disable Naming/ClassAndModuleCamelCase
    title 'UDAP Authorization Code Flow'
    description %(
      This group tests UDAP servers that support JWT authentication using an OAuth2.0 authorization_code grant flow and
       includes the following baseline UDAP sub-groups.

      1. Discovery Group
      2. Dynamic Client Registration
      3. Authorization and Authentication with SMART App Launch compliant scopes.

      There are also three additional test groups to assess conformance with SMART scopes:

      4. SMART/UDAP Launch Context - these tests will validate any SMART launch context parameters returned by the
      authorization server
      5. OpenID Connect - these tests will be executed if the `openid` scope was requested in step 3 and an ID token
      returned along with the access token
      6. Token Refresh - these tests will be executed if the `offline_access` or `online_access` scopes were requested
      and in step 3 and a refresh token was returned along with the original access token
    )
    id :smart_udap_authorization_code_group

    input_instructions %(
      **Discovery Tests**

      #{UDAPSecurityTestKit::DiscoveryGroup.discovery_group_input_instructions}

      **Dynamic Client Registration Tests**

      #{UDAPSecurityTestKit::DynamicClientRegistrationGroup.dynamic_client_registration_input_instructions}
    )

    group from: :udap_discovery_group,
          id: :auth_code_discovery_group,
          run_as_group: true,
          config: {
            inputs: {
              required_flow_type: {
                name: :flow_type_auth_code,
                title: 'Required OAuth2.0 Flow Type for Authorization Code Workflow',
                optional: false,
                default: ['authorization_code'],
                locked: true
              }
            }
          }
    group from: :udap_dynamic_client_registration_group,
          id: :auth_code_dcr_group,
          run_as_group: true,
          config: {
            inputs: {
              udap_registration_grant_type: {
                name: :reg_grant_type_auth_code,
                default: 'authorization_code',
                locked: true
              },
              udap_client_cert_pem: {
                name: :udap_auth_code_flow_client_cert_pem,
                title: 'Authorization Code Client Certificate(s) (PEM Format)'
              },
              udap_client_private_key_pem: {
                name: :udap_auth_code_flow_client_private_key,
                title: 'Authorization Code Client Private Key (PEM Format)'
              },
              udap_cert_iss: {
                name: :udap_auth_code_flow_cert_iss,
                title: 'Authorization Code JWT Issuer (iss) Claim'
              },
              udap_registration_requested_scope: {
                name: :udap_auth_code_flow_registration_scope,
                title: 'Authorization Code Registration Requested Scope(s)',
                description: %(
                  String containing a space delimited list of scopes requested by the client application for use in
                  subsequent requests. The Authorization Server MAY consider this list when deciding the scopes that it
                  will allow the application to subsequently request. Apps requesting the "authorization_code" grant
                  type SHOULD request user or patient scopes.
                )
              },
              udap_registration_certifications: {
                name: :udap_auth_code_flow_registration_certifications,
                title: 'Authorization Code UDAP Registration Certifications'
              }
            },
            outputs: {
              udap_client_cert_pem: {
                name: :udap_auth_code_flow_client_cert_pem
              },
              udap_client_private_key_pem: {
                name: :udap_auth_code_flow_client_private_key
              },
              udap_cert_iss: {
                name: :udap_auth_code_flow_cert_iss
              }
            }
          } do
      input_order :udap_registration_endpoint,
                  :reg_grant_type_auth_code,
                  :udap_auth_code_flow_client_cert_pem,
                  :udap_auth_code_flow_client_private_key,
                  :udap_auth_code_flow_cert_iss,
                  :udap_auth_code_flow_registration_scope,
                  :udap_jwt_signing_alg, :udap_auth_code_flow_registration_certifications
    end

    group from: :smart_udap_authorization_code_authentication_group

    group from: :smart_udap_launch_context

    group from: :smart_udap_openid_connect,
          optional: true

    group from: :smart_udap_token_refresh_without_scopes,
          optional: true

    group from: :smart_udap_token_refresh_with_scopes,
          optional: true
  end
end
