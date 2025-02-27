require 'udap_security_test_kit'
require_relative 'smart_udap_harmonization_test_kit/metadata'
require_relative 'smart_udap_harmonization_test_kit/smart_udap_authorization_code_group'

module SMART_UDAP_HarmonizationTestKit
  class Suite < Inferno::TestSuite
    id :smart_udap_harmonization
    title 'SMART-UDAP Harmonization'
    description %(
      ## Overview
      This test suite tests server support for the [Security for Scalable
      Registration, Authentication, and Authorization
      IG](https://hl7.org/fhir/us/udap-security/index.html) set of UDAP
      workflows (discovery, client registration, and
      authentication/authorization) using [SMART App Launch STU2-compliant
      scopes and launch
      contexts](https://hl7.org/fhir/smart-app-launch/STU2.2/scopes-and-launch-context.html).

      The [Security for Scalable Registration, Authentication, and Authorization
      IG](https://hl7.org/fhir/us/udap-security/index.html) states that

      > This guide is also intended to be compatible and harmonious with client and
      > server use of versions 1 or 2 of the HL7 SMART App Launch IG.

      This test kit is an effort to demonstrate how a client could interact with a
      server supporting both UDAP and SMART App Launch.

      The basic assumption underlying these tests is that a client could perform
      dynamic registration and launch with client authorization from the UDAP workflow
      while using SMART App Launch scopes, and the server could include additional
      launch context parameters defined by SMART App Launch in the token response.

      ## Known Limitations
      The UDAP dynamic registration workflow does not define a way to register a
      launch URI, so the tests only perform a standalone launch.
    )

    resume_test_route :get, '/redirect' do |request|
      request.query_parameters['state']
    end

    links [
      {
        type: 'report_issue',
        label: 'Report Issue',
        url: 'https://github.com/inferno-framework/smart-udap-harmonization-test-kit/issues/'
      },
      {
        type: 'source_code',
        label: 'Open Source',
        url: 'https://github.com/inferno-framework/smart-udap-harmonization-test-kit/'
      },
      {
        type: 'download',
        label: 'Download',
        url: 'https://github.com/inferno-framework/smart-udap-harmonization-test-kit/releases/'
      },
      {
        type: 'ig',
        label: 'UDAP Implementation Guide',
        url: 'https://hl7.org/fhir/us/udap-security/STU1'
      },
      {
        type: 'ig',
        label: 'SMART Implementation Guide',
        url: 'https://hl7.org/fhir/smart-app-launch/STU2.2/scopes-and-launch-context.html'
      }
    ]

    group from: :smart_udap_authorization_code_group
  end
end
