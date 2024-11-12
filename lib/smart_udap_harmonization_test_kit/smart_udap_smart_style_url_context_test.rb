require_relative 'smart_udap_context_test'

module SMART_UDAP_HarmonizationTestKit
  class SMART_UDAP_SmartStyleUrlContextTest < SMART_UDAP_ContextTest # rubocop:disable Naming/ClassAndModuleCamelCase
    id :smart_udap_smart_style_url_context
    title 'Support for "smart_style_url" launch context'
    description <<~DESCRIPTION
      This test validates the presence and format of the "smart_style_url"
      launch context. It then makes a GET request to the "smart_style_url" and
      verifies that the response is valid JSON.
    DESCRIPTION

    def context_field_name
      'smart_style_url'
    end

    def context_scopes
      [].freeze
    end

    def validate_context_field
      assert context_field.is_a?(String),
             "Expected `#{context_field_name}` to be a String, but found: `#{context_field.class.name}`"

      assert_valid_http_uri context_field

      get(token_response['smart_style_url'])

      assert_response_status(200)
      assert_valid_json(response[:body])
    end
  end
end
