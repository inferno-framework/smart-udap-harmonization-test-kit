require_relative 'smart_udap_context_test'

module SMART_UDAP_HarmonizationTestKit
  class SMART_UDAP_EncounterContextTest < SMART_UDAP_ContextTest
    id :smart_udap_encounter_context
    title 'Support for "encounter" launch context'
    description <<~DESCRIPTION
      This test validates the presence of the "encounter" launch context field if
      the `launch` or `launch/encounter` scopes were granted.

      If the "encounter" field is present, this test will the verify that it can
      retrieve that Encounter resource using the granted access token.
    DESCRIPTION

    FHIR_ID_REGEX = /[A-Za-z0-9\-\.]{1,64}/

    input :access_token
    input :udap_fhir_base_url,
          title: 'FHIR Server URL'

    fhir_client do
      url :udap_fhir_base_url
      bearer_token :access_token
    end

    def context_field_name
      'encounter'
    end

    def context_scopes
      ['launch', 'launch/encounter'].freeze
    end

    def missing_requested_context_scopes?
      context_scopes.none? { |scope| requested_scopes_list.include? scope }
    end

    def missing_received_context_scopes?
      # There is no expectation that Encounter context be included when just the
      # "launch" scope is used, so we shouldn't expect to see the "encounter"
      # context field just because "launch" was received
      received_scopes_list.exclude? 'launch/encounter'
    end

    def validate_context_field
      assert context_field.is_a?(String),
             "Expected `#{context_field_name}` to be a String, but found: `#{context_field.class.name}`"

      warn do
        assert context_field.match?(FHIR_ID_REGEX), "`#{context_field}` is not a valid FHIR resource id."
      end

      fhir_read(:encounter, context_field)

      assert_response_status(200)
      assert_resource_type(:encounter)
    end
  end
end
