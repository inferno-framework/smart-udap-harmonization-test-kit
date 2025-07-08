require_relative '../../lib/smart_udap_harmonization_test_kit/smart_udap_need_patient_banner_context_test'

RSpec.describe SMART_UDAP_HarmonizationTestKit::SMART_UDAP_NeedPatientBannerContextTest do # rubocop:disable RSpec/SpecFilePathFormat
  let(:suite_id) { :smart_udap_harmonization }
  let(:runnable) { find_test suite, 'smart_udap_need_patient_banner_context' }
  let(:udap_authorization_code_request_scopes) { 'launch/patient openid fhirUser offline_access patient/*.read' }
  let(:token_response_body) do
    {
      'access_token' => 'example_access_token',
      'refresh_token' => 'example_refresh_token',
      'id_token' => 'example_id_token',
      'token_type' => 'Bearer',
      'scope' => udap_authorization_code_request_scopes,
      'expires_in' => 3600,
      'patient' => 'EXAMPLE_PATIENT',
      'need_patient_banner' => false
    }
  end

  it 'skips if response body is not present' do
    result = run(runnable,
                 udap_authorization_code_request_scopes:,
                 token_response_body: '')
    expect(result.result).to eq('skip')
  end

  it 'fails if response body is not valid JSON' do
    invalid_response_body = '{invalid_key: invalid_value}'
    result = run(runnable,
                 udap_authorization_code_request_scopes:,
                 token_response_body: invalid_response_body)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/valid JSON/)
  end

  it 'fails if need_patient_banner context parameter not present in response body' do
    token_response_body.delete('need_patient_banner')
    result = run(runnable,
                 udap_authorization_code_request_scopes:,
                 token_response_body: JSON.generate(token_response_body))

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/did not contain `need_patient_banner` field/)
  end

  it 'fails if need_patient_banner context parameter value is not a boolean' do
    token_response_body['need_patient_banner'] = 'true'
    result = run(runnable,
                 udap_authorization_code_request_scopes:,
                 token_response_body: JSON.generate(token_response_body))

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/to be a boolean/)
  end

  it 'passes when need_patient_banner context parameter is a boolean' do
    result = run(runnable,
                 udap_authorization_code_request_scopes:,
                 token_response_body: JSON.generate(token_response_body))

    expect(result.result).to eq('pass')
  end
end
