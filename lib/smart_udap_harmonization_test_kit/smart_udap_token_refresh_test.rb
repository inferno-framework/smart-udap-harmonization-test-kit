require 'udap_security_test_kit/udap_client_assertion_payload_builder'
require 'udap_security_test_kit/udap_jwt_builder'
require_relative 'smart_udap_request_builder'
module SMART_UDAP_HarmonizationTestKit
  class SMART_UDAP_TokenRefreshTest < Inferno::Test
    title 'Server successfully refreshes the access token'
    id :smart_udap_token_refresh

    input :udap_client_id,
          title: 'Client ID'

    input :udap_token_endpoint,
          title: 'Token Endpoint',
          description: 'The full URL from which Inferno will request to exchange a refresh token for a new access token'

    # TODO: move this to the group level and parse it out there instead of
    # repeating it here?
    input :token_exchange_response_body,
          title: 'Token Exchange Response Body',
          type: 'textarea'

    input :udap_auth_code_flow_client_cert_pem,
          title: 'X.509 Client Certificate (PEM Format)',
          type: 'textarea',
          description: %(
            A list of one or more X.509 certificates in PEM format separated by a newline.
            The first (leaf) certificate MUST
            represent the client entity Inferno registered as,
            and the trust chain that will be built from the provided certificate(s) must resolve to a CA trusted by the
            authorization server under test.
          )

    input :udap_auth_code_flow_client_private_key,
          type: 'textarea',
          title: 'Client Private Key (PEM Format)',
          description: 'The private key corresponding to the X.509 client certificate'

    input :udap_jwt_signing_alg,
          title: 'JWT Signing Algorithm',
          description: %(
            Algorithm used to sign UDAP JSON Web Tokens (JWTs). UDAP Implementations SHALL support
            RS256.
            ),
          type: 'radio',
          options: {
            list_options: [
              {
                label: 'RS256',
                value: 'RS256'
              }
            ]
          },
          default: 'RS256',
          locked: true

    output :udap_token_refresh_response_body

    makes_request :smart_udap_token_refresh_request

    run do
      # TODO: omit if refresh token not present
      client_assertion_payload = UDAPClientAssertionPayloadBuilder.build(
        iss: udap_client_id,
        aud: udap_token_endpoint,
        extensions: nil
      )

      x5c_certs = UDAPJWTBuilder.split_user_input_cert_string(udap_auth_code_flow_client_cert_pem)

      client_assertion_jwt = UDAPJWTBuilder.encode_jwt_with_x5c_header(
        payload: client_assertion_payload,
        private_key: udap_auth_code_flow_client_private_key,
        alg: udap_jwt_signing_alg,
        x5c_certs_pem_string: x5c_certs
      )

      # TODO: change nil values to correct inputs once gem updated
      token_refresh_headers, token_refresh_body =
        SMART_UDAP_RequestBuilder.build_token_refresh_request(
          client_assertion_jwt:,
          refresh_token: nil,
          requested_scopes: nil
        )

      post(udap_token_endpoint,
           body: token_refresh_body,
           name: :token_exchange,
           headers: token_refresh_headers)

      assert_response_status(200)
      assert_valid_json(request.response_body)

      output token_retrieval_time: Time.now.iso8601

      output udap_token_refresh_response_body: request.response_body
    end
  end
end
