require_relative '../../lib/smart_udap_harmonization_test_kit/smart_udap_token_response_scope_test'

RSpec.describe SMART_UDAP_HarmonizationTestKit::SMART_UDAP_TokenResponseScopeTest do # rubocop:disable RSpec/SpecFilePathFormat
  let(:suite_id) { :smart_udap_harmonization }
  let(:runnable) { find_test suite, 'smart_udap_token_response_scope' }
  let(:udap_token_endpoint) { 'https://example.com/token' }
  let(:udap_authorization_code_request_scopes) { 'openid fhirUser offline_access patient/*.read' }
  let(:udap_client_id) { 'example_client_id' }
  let(:correct_response) do
    {
      'access_token' => 'example_access_token',
      'refresh_token' => 'example_refresh_token',
      'id_token' => 'example_id_token',
      'token_type' => 'Bearer',
      'scope' => udap_authorization_code_request_scopes,
      'expires_in' => 3600
    }
  end
  let(:udap_auth_code_flow_token_retrieval_time) { Time.now.iso8601 }

  it 'fails if response is not valid JSON' do
    invalid_response_body = '{invalid_key: invalid_value}'
    result = run(runnable,
                 udap_token_endpoint:,
                 udap_authorization_code_request_scopes:,
                 udap_auth_code_flow_registration_scope: udap_authorization_code_request_scopes,
                 udap_client_id:,
                 udap_auth_code_flow_token_exchange_response_body: invalid_response_body,
                 udap_auth_code_flow_token_retrieval_time:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/valid JSON/)
  end

  it 'fails if scope parameters is not present' do
    correct_response.delete('scope')
    result = run(runnable,
                 udap_token_endpoint:,
                 udap_authorization_code_request_scopes:,
                 udap_auth_code_flow_registration_scope: udap_authorization_code_request_scopes,
                 udap_client_id:,
                 udap_auth_code_flow_token_exchange_response_body: JSON.generate(correct_response),
                 udap_auth_code_flow_token_retrieval_time:)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/scope/)
  end

  it 'passes when response contains all required values' do
    result = run(runnable,
                 udap_token_endpoint:,
                 udap_authorization_code_request_scopes:,
                 udap_auth_code_flow_registration_scope: udap_authorization_code_request_scopes,
                 udap_client_id:,
                 udap_auth_code_flow_token_exchange_response_body: JSON.generate(correct_response),
                 udap_auth_code_flow_token_retrieval_time:)

    expect(result.result).to eq('pass')
  end

  it 'passes when scopes are missing from response but issues a warning' do
    correct_response['scope'] = 'openid fhirUser offline_access'
    result = run(runnable,
                 udap_token_endpoint:,
                 udap_authorization_code_request_scopes:,
                 udap_auth_code_flow_registration_scope: udap_authorization_code_request_scopes,
                 udap_client_id:,
                 udap_auth_code_flow_token_exchange_response_body: JSON.generate(correct_response),
                 udap_auth_code_flow_token_retrieval_time:)

    warning_messages = Inferno::Repositories::Messages.new.messages_for_result(result.id).filter do |message|
      message.type == 'warning'
    end

    expect(warning_messages).to be_any do |wm|
      wm.message.include? "\nToken exchange response did not include all requested scopes.\nThese may have " \
                          "been denied by user: `patient/*.read`.\n\n"
    end
    expect(result.result).to eq('pass')
  end
end
