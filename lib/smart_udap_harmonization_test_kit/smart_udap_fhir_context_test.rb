require_relative 'smart_udap_context_test'

module SMART_UDAP_HarmonizationTestKit # rubocop:disable Naming/ClassAndModuleCamelCase
  class SMART_UDAP_FHIR_ContextTest < SMART_UDAP_ContextTest # rubocop:disable Naming/ClassAndModuleCamelCase
    id :smart_udap_fhir_context
    title 'Support for "fhirContext" launch context'
    description <<~DESCRIPTION
      This test validates the presence and format of the "fhirContext"
      launch context.
    DESCRIPTION

    def context_field_name
      'fhirContext'
    end

    def context_scopes
      [].freeze
    end

    def validate_context_field
      assert context_field.is_a?(Array),
             "`fhirContext` field should be an Array, but found `#{context_field.class.name}`"

      context_field_types = context_field.map(&:class).uniq

      assert context_field_types.length == 1,
             "Inconsistent `fhirContext` types found: #{context_field_types.map(&:name).join(', ')}"

      if context_field.any? { |member| member.is_a? String }
        assert context_field.none? { |member| member&.start_with?('Patient/') || member&.start_with?('Encounter/') },
               'Patient and Encounter references are not permitted within fhirContext in SMART App Launch 2.0.0'

        pass
      end

      non_hash_fields = context_field.reject { |member| member.is_a? Hash }
      non_hash_fields_string = non_hash_fields.map { |member| "`#{member.class.name}`" }.join(', ')
      assert non_hash_fields.empty?,
             "All `fhirContext` elements should be JSON objects, but found #{non_hash_fields_string}"

      field_types = {
        'reference' => String,
        'canonical' => String,
        'identifier' => Hash,
        'type' => String,
        'role' => String
      }

      bad_fields = []
      context_field.each do |member|
        field_types.each do |name, type|
          if member.key?(name) && !member[name].is_a?(type)
            bad_fields << { name:, type: member[name].class.name, expected_type: type.name }
          end
        end
      end

      bad_types_list =
        bad_fields.map do |bad_field|
          "\n* `#{bad_field[:name]}` - Expected `#{bad_field[:expected_type]}`, but found `#{bad_field[:type]}`"
        end
      bad_types_message = "The following fields have incorrect types#{bad_types_list.join}"

      assert bad_fields.empty?, bad_types_message

      patient_and_encounter_references =
        context_field.select do |member|
          member['reference']&.start_with?('Patient/') || member['reference']&.start_with?('Encounter/')
        end
      good_patient_and_encounter_roles =
        patient_and_encounter_references.all? do |reference|
          reference['role'].present? && reference['role'] != 'launch'
        end

      assert good_patient_and_encounter_roles,
             'Patient and Encounter references are not allowed unless they have a role other than `launch`'

      assert context_field.all? { |member| member['role'].is_a?(String) ? member['role'].present? : true },
             '`role` SHALL NOT be an empty string'

      required_fields = ['reference', 'canonical', 'identifier']

      assert context_field.all? { |member| required_fields.any? { |field| member[field].present? } },
             'Each object in fhirContext SHALL include at least one of "reference", "canonical", or "identifier"'
    end
  end
end
