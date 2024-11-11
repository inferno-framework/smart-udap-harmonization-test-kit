require 'udap_security_test_kit/udap_client_assertion_payload_builder'
require 'udap_security_test_kit/udap_jwt_builder'
require_relative 'smart_udap_request_builder'
module SMART_UDAP_HarmonizationTestKit # rubocop:disable Naming/ClassAndModuleCamelCase
  class SMART_UDAP_TokenRefreshTest < Inferno::Test # rubocop:disable Naming/ClassAndModuleCamelCase
    title 'Server successfully refreshes the access token'
    id :smart_udap_token_refresh

    description %(
      This test will attempt to exchange the refresh token received in the original token exchange for a new access
      token. The test will skip if no refresh token was granted during the token exchange test.

      The [HL7 UDAP STU1.0 IG Section on Refresh Tokens](https://hl7.org/fhir/us/udap-security/STU1/consumer.html#refresh-tokens)
      defers to the refresh token exchange requirements outlined in [Section 6 of RFC 6749](https://datatracker.ietf.org/doc/html/rfc6749#section-6),
      which states:
      > If the client type is confidential or
        the client was issued client credentials (or assigned other
        authentication requirements), the client MUST authenticate with the
        authorization server as described in [Section 3.2.1](https://datatracker.ietf.org/doc/html/rfc6749#section-3.2.1).

      RFC 6749 section 3.2.1 references [section 2.3](https://datatracker.ietf.org/doc/html/rfc6749#section-2.3), which
      states:
      > The client and authorization
        server establish a client authentication method suitable for the
        security requirements of the authorization server.  The authorization
        server MAY accept any form of client authentication meeting its
        security requirements.

      Therefore, Inferno will authenticate to the authorization server using the same UDAP authentication method
      described in the [HL7 UDAP Consumer Facing Authentication Section 4.2](https://hl7.org/fhir/us/udap-security/STU1/consumer.html#obtaining-an-access-token),
      with the following changes:
      * `code` and `redirect_uri` parameters are omitted
      * `grant_type` is set to `refresh_token` per [Section 6 of RFC 6749](https://datatracker.ietf.org/doc/html/rfc6749#section-6)
      * `refresh_token` is included
    )

    input :udap_client_id,
          title: 'Client ID'

    input :udap_token_endpoint,
          title: 'Token Endpoint',
          description: 'The full URL from which Inferno will request to exchange a refresh token for a new access token'

    input :udap_refresh_token,
          title: 'Refresh Token',
          type: 'textarea'

    input :udap_received_scopes,
          title: 'Requested Scopes',
          description: 'A list of scopes that will be requested during token exchange.'

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

    output :smart_udap_refresh_token_retrieval_time,
           :smart_udap_token_refresh_response_body

    makes_request :smart_udap_token_refresh_request

    run do
      client_assertion_payload = UDAPSecurityTestKit::UDAPClientAssertionPayloadBuilder.build(
        udap_client_id,
        udap_token_endpoint,
        nil
      )

      x5c_certs = UDAPSecurityTestKit::UDAPJWTBuilder.split_user_input_cert_string(udap_auth_code_flow_client_cert_pem)

      client_assertion_jwt = UDAPSecurityTestKit::UDAPJWTBuilder.encode_jwt_with_x5c_header(
        client_assertion_payload,
        udap_auth_code_flow_client_private_key,
        udap_jwt_signing_alg,
        x5c_certs
      )

      requested_scopes = (udap_received_scopes if config.options[:include_scopes])

      token_refresh_headers, token_refresh_body =
        SMART_UDAP_RequestBuilder.build_token_refresh_request(
          client_assertion_jwt,
          udap_refresh_token,
          requested_scopes
        )

      post(udap_token_endpoint,
           body: token_refresh_body,
           name: :token_exchange,
           headers: token_refresh_headers)

      assert_response_status(200)
      assert_valid_json(request.response_body)

      output smart_udap_refresh_token_retrieval_time: Time.now.iso8601

      output smart_udap_token_refresh_response_body: request.response_body
    end
  end
end
