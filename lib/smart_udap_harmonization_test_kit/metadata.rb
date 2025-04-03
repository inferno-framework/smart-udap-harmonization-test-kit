require_relative 'version'

module SMART_UDAP_HarmonizationTestKit
  class Metadata < Inferno::TestKit
    id :smart_udap_harmonization
    title 'SMART-UDAP Harmonization Test Kit'
    description <<~DESCRIPTION
      The SMART-UDAP Harmonization Test Kit is an experimental Test Kit for evaluating
      options for testing authorization systems that conform to both SMART App Launch
      Implementation Guide and the Security for Scalable Registration, Authentication
      and Authorization Implementation Guide requirements.
      <!-- break -->
      The [Security for Scalable Registration, Authentication, and Authorization
      IG](https://hl7.org/fhir/us/udap-security/index.html) states, "This guide is also
      intended to be compatible and harmonious with client and server use of versions
      1 or 2 of the HL7 SMART App Launch IG.”

      This test kit is an effort to demonstrate how a client could interact with a server
      supporting both UDAP and SMART App Launch.

      ## Overview

      The basic assumption underlying these tests is that a client could perform
      dynamic registration and launch with client authorization from the UDAP workflow
      while using SMART App Launch scopes, and the server could include additional
      launch context parameters defined by SMART App Launch in the token response.

      The tests begin with normal parts of the UDAP workflow: discovery, dynamic
      registration, and authorization.

      Then there are tests for SMART App Launch context parameters which could be
      included as part of the token response, including an OpenIDConnect id token.
      Finally, there are tests for token refresh.

      ## Known Limitations

      The UDAP dynamic registration workflow does not define a way to register a
      launch URI, so the tests only perform a standalone launch.

      ## Reporting Issues

      Please report any issues with this set of tests in the [GitHub Issues](https://github.com/inferno-framework/smart-udap-harmonization-test-kit/issues) section of the [open-source code repository](https://github.com/inferno-framework/smart-udap-harmonization-test-kit).
    DESCRIPTION
    suite_ids [:smart_udap_harmonization]
    tags ['UDAP', 'SMART App Launch']
    last_updated LAST_UPDATED
    version VERSION
    maturity 'Low'
    authors ['Alisa Wallace']
    repo 'https://github.com/inferno-framework/smart-udap-harmonization-test-kit'
  end
end
