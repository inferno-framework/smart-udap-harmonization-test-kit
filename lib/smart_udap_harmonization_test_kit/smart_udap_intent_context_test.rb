require_relative '../smart_udap_context_test'

module SMART_UDAP_HarmonizationTestKit
  class SMART_UDAP_IntentContextTest < SMART_UDAP_ContextTest
    id :smart_udap_intent_context
    title 'Support for "intent" launch context'
    description <<~DESCRIPTION
      This test validates the presence and format of the "intent"
      launch context.
    DESCRIPTION

    fhir_client do
      url :url
      bearer_token :access_token
    end

    def context_field_name
      'intent'
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
