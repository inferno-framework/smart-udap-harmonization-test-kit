require 'smart_app_launch_test_kit'
require 'udap_security_test_kit'

require_relative 'smart_udap_harmonization_test_kit/smart_discovery_group'
require_relative 'smart_udap_harmonization_test_kit/authorization_code_workflow_group'

module SMARTUDAPHarmonizationTestKit
  class Suite < Inferno::TestSuite
    id :smart_udap_harmonization
    title 'SMART-UDAP Harmonization'
    description %(
      This test kit tests server support for the [HL7 UDAP STU1.0 IG](https://hl7.org/fhir/us/udap-security/STU1/index.html) set of UDAP workflows (discovery, client registration, and authentication/authorization) using SMART App Launch scopes ([STU1](https://hl7.org/fhir/smart-app-launch/1.0.0/scopes-and-launch-context/index.html) or [STU2](https://hl7.org/fhir/smart-app-launch/STU2.2/scopes-and-launch-context.html)).

      Conformant systems are expected to comply with all UDAP requirements, with the exception of requirements pertaining to scopes, where the system is expected to comply with SMART App Launch scopes requirements.  No other requirements from the SMART App Launch framework are assessed. 
    )

    # # These inputs will be available to all tests in this suite
    # input :fhir_base_url,
    #       title: 'FHIR Server Base Url'

    # input :credentials,
    #       title: 'OAuth Credentials',
    #       type: :oauth_credentials,
    #       optional: true

    # # All FHIR requests in this suite will use this FHIR client
    # fhir_client do
    #   url :fhir_base_url
    #   oauth_credentials :credentials
    # end

    group from: :harmonization_smart_discovery_group
    group from: :harmonization_authorization_code_workflow_group
  end
end
