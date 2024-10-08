require 'udap_security_test_kit'
require_relative 'smart_udap_harmonization_test_kit/harmonization_authorization_code_group'

module SMARTUDAPHarmonizationTestKit
  class Suite < Inferno::TestSuite
    id :smart_udap_harmonization
    title 'SMART-UDAP Harmonization'
    description %(
      This test kit tests server support for the [HL7 UDAP STU1.0 IG](https://hl7.org/fhir/us/udap-security/STU1/index.html) set of UDAP workflows (discovery, client registration, and authentication/authorization) using [SMART App Launch STU2 scopes](https://hl7.org/fhir/smart-app-launch/STU2.2/scopes-and-launch-context.html).

      Conformant systems are expected to comply with all UDAP requirements, with the exception of requirements pertaining to scopes, where the system is expected to comply with SMART App Launch STU2 scopes requirements.  No other requirements from the SMART App Launch framework are assessed. 
    )

    resume_test_route :get, '/redirect' do |request|
      request.query_parameters['state']
    end

    config options: {
      redirect_uri: "#{Inferno::Application['base_url']}/custom/smart_udap_harmonization_test_kit/redirect",
    }
   
    group from: :harmonization_authorization_code_group
  end
end
