require_relative './smart_udap_encounter_context_test'
require_relative './smart_udap_intent_context_test'
require_relative './smart_udap_need_patient_banner_context_test'
require_relative './smart_udap_patient_context_test'

module SMART_UDAP_HarmonizationTestKit
  class SMART_UDAP_LaunchContextGroup < Inferno::TestGroup
    title 'SMART/UDAP Launch Context'
    id :smart_udap_launch_context
    description <<~DESCRIPTION
    DESCRIPTION

    test from: :smart_udap_patient_context

    test from: :smart_udap_encounter_context

    # TODO: fhirContext - deal with multi-version support or not?

    test from: :smart_udap_need_patient_banner_context

    test from: :smart_udap_intent_context

    # smart_style_url
    # tenant
    # id_token
    # refresh_token
  end
end
