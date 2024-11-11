require_relative '../../lib/smart_udap_harmonization_test_kit/smart_udap_smart_style_url_context_test'

RSpec.describe SMART_UDAP_HarmonizationTestKit::SMART_UDAP_SmartStyleUrlContextTest do # rubocop:disable RSpec/SpecFilePathFormat
  let(:runnable) { Inferno::Repositories::Tests.new.find('smart_udap_smart_style_url_context') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:results_repo) { Inferno::Repositories::Results.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'smart_udap_harmonization') }
  let(:udap_auth_code_flow_registration_scope) { 'launch/patient openid fhirUser offline_access patient/*.read' }
  let(:smart_style_url) { 'http://example.com/smart_style_url' }
  let(:token_response_body) do
    {
      'access_token' => 'example_access_token',
      'refresh_token' => 'example_refresh_token',
      'id_token' => 'example_id_token',
      'token_type' => 'Bearer',
      'scope' => udap_auth_code_flow_registration_scope,
      'expires_in' => 3600,
      'patient' => 'EXAMPLE_PATIENT',
      'smart_style_url' => smart_style_url
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

  it 'fails if smart_style_url context parameter not present in response body' do
    token_response_body.delete('smart_style_url')
    result = run(runnable,
                 udap_auth_code_flow_registration_scope:,
                 token_response_body: JSON.generate(token_response_body))

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/did not contain `smart_style_url` field/)
  end

  it 'fails if need_patient_banner context parameter value is not a String' do
    token_response_body['smart_style_url'] = 1234
    result = run(runnable,
                 udap_auth_code_flow_registration_scope:,
                 token_response_body: JSON.generate(token_response_body))

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/to be a String/)
  end

  it 'fails if need_patient_banner context parameter value is not a valid HTTP URI' do
    token_response_body['smart_style_url'] = 'not a URI'
    result = run(runnable,
                 udap_auth_code_flow_registration_scope:,
                 token_response_body: JSON.generate(token_response_body))

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/not a valid URI/)
  end

  it 'fails if smart_styling URL does not return a 200 response code' do
    stub_request(:get, smart_style_url)
      .to_return(status: 404, body: {}.to_json, headers: {})

    result = run(runnable,
                 udap_auth_code_flow_registration_scope:,
                 token_response_body: JSON.generate(token_response_body))

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/expected 200, but received 404/)
  end

  it 'passes if smart_stying URL returns valid JSON response body' do
    stub_request(:get, smart_style_url)
      .to_return(status: 200, body: { 'color_background' => '#edeae3' }.to_json, headers: {})

    result = run(runnable,
                 udap_auth_code_flow_registration_scope:,
                 token_response_body: JSON.generate(token_response_body))

    expect(result.result).to eq('pass')
  end
end
