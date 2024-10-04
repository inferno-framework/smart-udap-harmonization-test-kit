require_relative './smart_udap_encounter_context_test'
require_relative './smart_udap_patient_context_test'

module SMART_UDAP_HarmonizationTestKit
  class SMART_UDAP_LaunchContextGroup < Inferno::TestGroup
    title 'SMART/UDAP Launch Context'
    id :smart_udap_launch_context
    description <<~DESCRIPTION
    DESCRIPTION

    test from: :smart_udap_patient_context
    test from: :smart_udap_encounter_context

    # fhirContext
    # need_patient_banner
    # intent
    # smart_style_url
    # tenant
    # id_token
    # refresh_token
  end
end
