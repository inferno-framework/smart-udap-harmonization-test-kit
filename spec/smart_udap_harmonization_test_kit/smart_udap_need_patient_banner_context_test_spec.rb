require_relative '../../lib/smart_udap_harmonization_test_kit/smart_udap_need_patient_banner_context_test'

RSpec.describe SMART_UDAP_HarmonizationTestKit::SMART_UDAP_NeedPatientBannerContextTest do
  let(:runnable) { Inferno::Repositories::Tests.new.find('smart_udap_need_patient_banner_context') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:results_repo) { Inferno::Repositories::Results.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'smart_udap_harmonization') }
  let(:udap_registration_scope_auth_code_flow) { 'launch/patient openid fhirUser offline_access patient/*.read' }
  let(:token_response_body) do
    {
      'access_token' => 'example_access_token',
      'refresh_token' => 'example_refresh_token',
      'id_token' => 'example_id_token',
      'token_type' => 'Bearer',
      'scope' => udap_registration_scope_auth_code_flow,
      'expires_in' => 3600,
      'patient' => 'EXAMPLE_PATIENT',
      'need_patient_banner' => false
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
                 udap_registration_scope_auth_code_flow:,
                 token_response_body: '')
    expect(result.result).to eq('skip')
  end

  it 'fails if response body is not valid JSON' do
    invalid_response_body = '{invalid_key: invalid_value}'
    result = run(runnable,
                 udap_registration_scope_auth_code_flow:,
                 token_response_body: invalid_response_body)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/valid JSON/)
  end

  # TODO: spec does not list this as required, should it omit instead of fail?
  # https://hl7.org/fhir/smart-app-launch/STU2/scopes-and-launch-context.html#launch-context-arrives-with-your-access_token
  it 'fails if need_patient_banner context parameter not present in response body' do
    token_response_body.delete('need_patient_banner')
    result = run(runnable,
                 udap_registration_scope_auth_code_flow:,
                 token_response_body: JSON.generate(token_response_body))

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/did not contain `need_patient_banner` field/)
  end

  it 'fails if need_patient_banner context parameter value is not a boolean' do
    token_response_body['need_patient_banner'] = 'true'
    result = run(runnable,
                 udap_registration_scope_auth_code_flow:,
                 token_response_body: JSON.generate(token_response_body))

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/to be a boolean/)
  end

  it 'passes when need_patient_banner context parameter is a boolean' do
    result = run(runnable,
                 udap_registration_scope_auth_code_flow:,
                 token_response_body: JSON.generate(token_response_body))

    expect(result.result).to eq('pass')
  end
end
