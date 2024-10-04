module SMART_UDAP_HarmonizationTestKit
  class SMART_UDAP_ContextTest < Inferno::Test
    attr_accessor :token_response

    input :token_response_body
    input :udap_software_statement_json

    def context_field
      token_response[context_field_name]
    end

    def received_scopes
      token_response['scope'] || ''
    end

    def requested_scopes
      @requested_scopes ||=
        begin
          assert_valid_json(udap_software_statement_json)
          JSON.parse(udap_software_statement_json)['scope']
        end
    end

    def missing_requested_context_scopes
      @missing_requested_context_scopes ||=
        context_scopes.reject { |scope| requested_scopes_list.include? scope }
    end

    def missing_received_context_scopes
      @missing_received_context_scopes ||=
        context_scopes.reject { |scope| received_scopes_list.include? scope }
    end

    def received_scopes_list
      @received_scopes_list ||= received_scopes.split(' ')
    end

    def requested_scopes_list
      @requested_scopes_list ||= requested_scopes.split(' ')
    end

    def missing_requested_scopes_string
      missing_requested_context_scopes
        .map { |scope| "`#{scope}`" }
        .join(', ')
    end

    def missing_received_scopes_string
      missing_received_context_scopes
        .map { |scope| "`#{scope}`" }
        .join(', ')
    end

    def missing_requested_context_scopes?
      missing_requested_context_scopes.present?
    end

    def missing_received_context_scopes?
      missing_received_context_scopes.present?
    end

    def context_field_present?
      context_field.present? || context_field == false
    end

    run do
      assert_present(token_response_body)
      assert_valid_json(token_response_body)
      self.token_response = JSON.parse(token_response_body)

      if context_field_present?
        if missing_requested_context_scopes?
          info "`#{context_field_name}` field is present in token response even though #{missing_requested_scopes_string} was not requested"
        end
        if missing_received_context_scopes?
          warn "`#{context_field_name}` field is present in token response even though #{missing_received_scopes_string} was not received"
        end
      end

      if !missing_received_context_scopes?
        assert context_field_present?
      end

      skip_if !context_field_present?, "Token response did not contain `#{context_field_name}` field."

      validate_context_field
    end
  end
end