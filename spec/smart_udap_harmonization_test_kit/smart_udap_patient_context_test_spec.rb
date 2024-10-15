require_relative '../../lib/smart_udap_harmonization_test_kit/smart_udap_patient_context_test'

RSpec.describe SMART_UDAP_HarmonizationTestKit::SMART_UDAP_PatientContextTest do
  let(:runnable) { Inferno::Repositories::Tests.new.find('smart_udap_patient_context') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:results_repo) { Inferno::Repositories::Results.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'smart_udap_harmonization') }

  let(:access_token) { 'example_access_token' }
  let(:udap_fhir_base_url) { 'https://example.com' }
  let(:udap_registration_scope_auth_code_flow) { 'launch/patient openid fhirUser offline_access patient/*.read' }
  let(:scope_no_launch_patient) { 'openid fhirUser offline_access patient/*.read' }
  let(:token_response_body) do
    {
      'access_token' => access_token,
      'refresh_token' => 'example_refresh_token',
      'id_token' => 'example_id_token',
      'token_type' => 'Bearer',
      'scope' => udap_registration_scope_auth_code_flow,
      'expires_in' => 3600,
      'patient' => 'EXAMPLE_PATIENT'
    }
  end
  let(:token_retrieval_time) { Time.now.iso8601 }
  let(:patient_id) { 'patient_id' }

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
                 udap_fhir_base_url:,
                 access_token:,
                 udap_registration_scope_auth_code_flow:,
                 token_response_body: '')
    expect(result.result).to eq('skip')
  end

  it 'fails if response body is not valid JSON' do
    invalid_response_body = '{invalid_key: invalid_value}'
    result = run(runnable,
                 udap_fhir_base_url:,
                 access_token:,
                 udap_registration_scope_auth_code_flow:,
                 token_response_body: invalid_response_body)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/valid JSON/)
  end

  context 'when patient context parameter requested but omitted from response body' do
    it 'fails if launch/patient included in received scopes' do
      token_response_body.delete('patient')

      result = run(runnable,
                   udap_fhir_base_url:,
                   access_token:,
                   udap_registration_scope_auth_code_flow:,
                   token_response_body: JSON.generate(token_response_body))
      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/did not contain `patient` field/)
    end

    it 'skips if launch/encounter omitted from received scopes' do
      token_response_body['scope'] = scope_no_launch_patient
      token_response_body.delete('patient')

      result = run(runnable,
                   udap_fhir_base_url:,
                   access_token:,
                   udap_registration_scope_auth_code_flow:,
                   token_response_body: JSON.generate(token_response_body))
      expect(result.result).to eq('skip')
      expect(result.result_message).to match(/did not contain `patient` field/)
    end
  end

  context 'when patient context parameter requested and included in response body' do
    context 'when referenced patient resource is valid' do
      it 'passes if launch/patient included in received scopes' do
        stub_request(:get, 'https://example.com/Patient/EXAMPLE_PATIENT')
          .to_return(status: 200, body: FHIR::Patient.new(id: patient_id).to_json, headers: {})

        result = run(runnable,
                     udap_fhir_base_url:,
                     access_token:,
                     udap_registration_scope_auth_code_flow:,
                     token_response_body: JSON.generate(token_response_body))
        expect(result.result).to eq('pass')
      end

      it 'passes if launch/patient omitted from received scopes' do
        stub_request(:get, 'https://example.com/Patient/EXAMPLE_PATIENT')
          .to_return(status: 200, body: FHIR::Patient.new(id: patient_id).to_json, headers: {})

        token_response_body['scope'] = scope_no_launch_patient

        result = run(runnable,
                     udap_fhir_base_url:,
                     access_token:,
                     udap_registration_scope_auth_code_flow:,
                     token_response_body: JSON.generate(token_response_body))
        expect(result.result).to eq('pass')
      end
    end

    context 'when referenced patient resource is invalid' do
      it 'fails when patient value is not a String' do
        token_response_body['patient'] = 1234

        result = run(runnable,
                     udap_fhir_base_url:,
                     access_token:,
                     udap_registration_scope_auth_code_flow:,
                     token_response_body: JSON.generate(token_response_body))
        expect(result.result).to eq('fail')
        expect(result.result_message).to match(/to be a String/)
      end

      it 'fails when get request does not return 200 response code' do
        stub_request(:get, 'https://example.com/Patient/EXAMPLE_PATIENT')
          .to_return(status: 401, body: {}.to_json, headers: {})

        result = run(runnable,
                     udap_fhir_base_url:,
                     access_token:,
                     udap_registration_scope_auth_code_flow:,
                     token_response_body: JSON.generate(token_response_body))
        expect(result.result).to eq('fail')
        expect(result.result_message).to match(/expected 200, but received 401/)
      end

      it 'fails when get request does not return valid FHIR encounter resource' do
        stub_request(:get, 'https://example.com/Patient/EXAMPLE_PATIENT')
          .to_return(status: 200, body: FHIR::Observation.new(id: patient_id).to_json, headers: {})

        result = run(runnable,
                     udap_fhir_base_url:,
                     access_token:,
                     udap_registration_scope_auth_code_flow:,
                     token_response_body: JSON.generate(token_response_body))
        expect(result.result).to eq('fail')
        expect(result.result_message).to match(/expected Patient, but received Observation/)
      end
    end
  end
end
