require_relative 'smart_udap_context_test'

module SMART_UDAP_HarmonizationTestKit
  class SMART_UDAP_NeedPatientBannerContextTest < SMART_UDAP_ContextTest # rubocop:disable Naming/ClassAndModuleCamelCase
    id :smart_udap_need_patient_banner_context
    title 'Support for "need_patient_banner" launch context'
    description <<~DESCRIPTION
      This test validates the presence and format of the "need_patient_banner"
      launch context.
    DESCRIPTION

    def context_field_name
      'need_patient_banner'
    end

    def context_scopes
      [].freeze
    end

    def validate_context_field
      assert context_field == true || context_field == false,
             "Expected `#{context_field_name}` to be a boolean, but found `#{context_field.class.name}`"
    end
  end
end
