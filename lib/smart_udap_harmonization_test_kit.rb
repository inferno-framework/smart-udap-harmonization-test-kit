require 'smart_app_launch_test_kit'
require 'udap_security_test_kit'

require_relative 'smart_udap_harmonization_test_kit/discovery_group'

module SMARTUDAPHarmonizationTestKit
  class Suite < Inferno::TestSuite
    id :smart_udap_harmonization
    title 'SMART-UDAP Harmonization Test Suite'
    description %(
      This suite is an initial investigation into requirements for a server adhering to both SMART App Launch STU2.0 and
      UDAP Security STU1.0 standards.
    )

    # These inputs will be available to all tests in this suite
    input :fhir_base_url,
          title: 'FHIR Server Base Url'

    input :credentials,
          title: 'OAuth Credentials',
          type: :oauth_credentials,
          optional: true

    # All FHIR requests in this suite will use this FHIR client
    fhir_client do
      url :fhir_base_url
      oauth_credentials :credentials
    end

    group from: :smart_udap_discovery_group
  end
end
