require_relative 'smart_udap_context_test'

module SMART_UDAP_HarmonizationTestKit # rubocop:disable Naming/ClassAndModuleCamelCase
  class SMART_UDAP_PatientContextTest < SMART_UDAP_ContextTest # rubocop:disable Naming/ClassAndModuleCamelCase
    id :smart_udap_patient_context
    title 'Support for "patient" launch context'
    description <<~DESCRIPTION
      This test validates the presence of the "patient" launch context field if
      the `launch` or `launch/patient` scopes were granted.

      If the "patient" field is present, this test will the verify that it can
      retrieve that Patient resource using the granted access token.
    DESCRIPTION

    FHIR_ID_REGEX = /[A-Za-z0-9\-\.]{1,64}/

    input :access_token,
          title: 'Access Token',
          description: 'Access token granted by authorization server.'
    input :udap_fhir_base_url,
          title: 'FHIR Server URL'

    fhir_client do
      url :udap_fhir_base_url
      bearer_token :access_token
    end

    def context_field_name
      'patient'
    end

    def context_scopes
      ['launch', 'launch/patient'].freeze
    end

    def missing_requested_context_scopes?
      context_scopes.none? { |scope| requested_scopes_list.include? scope }
    end

    def missing_received_context_scopes?
      context_scopes.none? { |scope| received_scopes_list.include? scope }
    end

    def validate_context_field
      assert context_field.is_a?(String),
             "Expected `#{context_field_name}` to be a String, but found: `#{context_field.class.name}`"

      warn do
        assert context_field.match?(FHIR_ID_REGEX), "`#{context_field}` is not a valid FHIR resource id."
      end

      fhir_read(:patient, context_field)

      assert_response_status(200)
      assert_resource_type(:patient)
    end
  end
end
