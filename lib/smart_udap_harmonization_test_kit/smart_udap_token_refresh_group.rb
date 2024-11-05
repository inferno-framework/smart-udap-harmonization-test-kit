require_relative 'smart_udap_token_refresh_test'

module SMART_UDAP_HarmonizationTestKit
  class SMART_UDAP_TokenRefreshGroup < Inferno::TestGroup
    title 'Support for Token Refresh'
    id :smart_udap_token_refresh

    description %(
      This group tests the ability of the system to successfully
      exchange a refresh token for an access token. Refresh tokens are typically
      longer lived than access tokens and allow client applications to obtain a
      new access token Refresh tokens themselves cannot provide access to
      resources on the server.

      Per the [HL7 UDAP STU1.0 IG Section on Refresh Tokens](https://hl7.org/fhir/us/udap-security/STU1/consumer.html#refresh-tokens)
      authorization server support for refresh tokens is optional:
      >This guide supports the use of refresh tokens, as described in [Section 1.5 of RFC 6749](https://datatracker.ietf.org/doc/html/rfc6749#section-1.5).
      >Authorization Servers **MAY** issue refresh tokens to consumer-facing client applications as per
      >[Section 5 of RFC 6749](https://datatracker.ietf.org/doc/html/rfc6749#section-5).
      >Client apps that have been issued refresh tokens **MAY** make refresh requests to the token endpoint as per
      >[Section 6 of RFC 6749](https://datatracker.ietf.org/doc/html/rfc6749#section-6).

      These tests will execute if the authorization server granted a refresh token during the authorization and
      authentication tests. They will attempt to exchange the refresh token for a new access token via a POST request
      to the token exchange endpoint and then verify the information returned as done in Section 1.3 tests 4-6.
    )

    # TODO: add in a setup test here that will parse out the refresh token and
    # received scopes for the group

    # TODO: add subgroups here for with/without scopes (just update a config variable)
    test from: :smart_udap_token_refresh
  end
end