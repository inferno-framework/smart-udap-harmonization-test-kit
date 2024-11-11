require_relative '../../lib/smart_udap_harmonization_test_kit/smart_udap_tenant_context_test'

RSpec.describe SMART_UDAP_HarmonizationTestKit::SMART_UDAP_TenantContextTest do
  let(:runnable) { Inferno::Repositories::Tests.new.find('smart_udap_tenant_context') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:results_repo) { Inferno::Repositories::Results.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'smart_udap_harmonization') }
  let(:udap_auth_code_flow_registration_scope) { 'launch/patient openid fhirUser offline_access patient/*.read' }
  let(:token_response_body) do
    {
      'access_token' => 'example_access_token',
      'refresh_token' => 'example_refresh_token',
      'id_token' => 'example_id_token',
      'token_type' => 'Bearer',
      'scope' => udap_auth_code_flow_registration_scope,
      'expires_in' => 3600,
      'patient' => 'EXAMPLE_PATIENT',
      'tenant' => 'EXAMPLE_TENANT'
    }
  end

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
                 udap_auth_code_flow_registration_scope:,
                 token_response_body: '')
    expect(result.result).to eq('skip')
  end

  it 'fails if response body is not valid JSON' do
    invalid_response_body = '{invalid_key: invalid_value}'
    result = run(runnable,
                 udap_auth_code_flow_registration_scope:,
                 token_response_body: invalid_response_body)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/valid JSON/)
  end

  it 'fails if tenant context parameter not present in response body' do
    token_response_body.delete('tenant')
    result = run(runnable,
                 udap_auth_code_flow_registration_scope:,
                 token_response_body: JSON.generate(token_response_body))

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/did not contain `tenant` field/)
  end

  it 'fails if tenant launch context parameter value is not a String' do
    token_response_body['intent'] = 1234
    result = run(runnable,
                 udap_auth_code_flow_registration_scope:,
                 token_response_body: JSON.generate(token_response_body))

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/to be a String/)
  end

  it 'passes when tenant launch context parameter is a String' do
    result = run(runnable,
                 udap_auth_code_flow_registration_scope:,
                 token_response_body: JSON.generate(token_response_body))

    expect(result.result).to eq('pass')
  end
end
