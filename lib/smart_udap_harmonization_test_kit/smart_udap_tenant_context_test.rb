require_relative 'smart_udap_context_test'

module SMART_UDAP_HarmonizationTestKit # rubocop:disable Naming/ClassAndModuleCamelCase
  class SMART_UDAP_TenantContextTest < SMART_UDAP_ContextTest # rubocop:disable Naming/ClassAndModuleCamelCase
    id :smart_udap_tenant_context
    title 'Support for "tenant" launch context'
    description <<~DESCRIPTION
      This test validates the presence and format of the "tenant"
      launch context.
    DESCRIPTION

    def context_field_name
      'tenant'
    end

    def context_scopes
      [].freeze
    end

    def validate_context_field
      assert context_field.is_a?(String),
             "Expected `#{context_field_name}` to be a String, but found: `#{context_field.class.name}`"
    end
  end
end
