require_relative '../../lib/smart_udap_harmonization_test_kit/smart_udap_encounter_context_test'

RSpec.describe SMART_UDAP_HarmonizationTestKit::SMART_UDAP_EncounterContextTest do
  let(:runnable) { Inferno::Repositories::Tests.new.find('smart_udap_encounter_context') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:results_repo) { Inferno::Repositories::Results.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'smart_udap_harmonization') }

  let(:access_token) { 'example_access_token' }
  let(:url) { 'https://example.com' }
  let(:udap_registration_scope_auth_code_flow) { 'openid fhirUser offline_access patient/*.read' }
  let(:response_body) do
    {
      'access_token' => access_token,
      'refresh_token' => 'example_refresh_token',
      'id_token' => 'example_id_token',
      'token_type' => 'Bearer',
      'scope' => udap_registration_requested_scope,
      'expires_in' => 3600,
      'encounter' => 'encounter'
    }
  end
  let(:token_retrieval_time) { Time.now.iso8601 }

  def run(runnable, inputs = {})
    test_run_params = { test_session_id: test_session.id }.merge(runnable.reference_hash)
    test_run = Inferno::Repositories::TestRuns.new.create(test_run_params)
    inputs.each do |name, value|
      session_data_repo.save(
        test_session_id: test_session.id,
        name:,
        value:,
        type: runnable.config.input_type(name)
      )
    end
    Inferno::TestRunner.new(test_session:, test_run:).run(runnable)
  end

  it 'skips if response body is not present' do
    result = run(runnable,
                 access_token:,
                 udap_registration_scope_auth_code_flow:,
                 token_response_body: '')
    expect(result.result).to eq('skip')
  end

  it 'fails if response is not valid JSON' do
    invalid_response_body = '{invalid_key: invalid_value}'
    result = run(runnable,
                 access_token:,
                 udap_registration_scope_auth_code_flow:,
                 token_response_body: invalid_response_body)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/valid JSON/)
  end

  # it 'fails if scope parameters is not present' do
  #   correct_response.delete('scope')
  #   result = run(runnable,
  #                udap_token_endpoint:,
  #                udap_registration_requested_scope:,
  #                udap_client_id:,
  #                token_response_body: JSON.generate(correct_response),
  #                token_retrieval_time:)
  #   expect(result.result).to eq('fail')
  #   expect(result.result_message).to match(/scope/)
  # end

  # it 'passes when response contains all required values' do
  #   result = run(runnable,
  #                udap_token_endpoint:,
  #                udap_registration_requested_scope:,
  #                udap_client_id:,
  #                token_response_body: JSON.generate(correct_response),
  #                token_retrieval_time:)

  #   expect(result.result).to eq('pass')
  # end

  # it 'passes when scopes are missing from response' do
  #   correct_response['scope'] = 'openid fhirUser offline_access'
  #   result = run(runnable,
  #                udap_token_endpoint:,
  #                udap_registration_requested_scope:,
  #                udap_client_id:,
  #                token_response_body: JSON.generate(correct_response),
  #                token_retrieval_time:)

  #   # Is there a way to test for warnings?
  #   expect(result.result).to eq('pass')
  # end
end
