require_relative '../../lib/smart_udap_harmonization_test_kit/smart_udap_intent_context_test'

RSpec.describe SMART_UDAP_HarmonizationTestKit::SMART_UDAP_IntentContextTest do
  let(:runnable) { Inferno::Repositories::Tests.new.find('smart_udap_fhir_context') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:results_repo) { Inferno::Repositories::Results.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'smart_udap_harmonization') }
  let(:udap_auth_code_flow_registration_scope) { 'launch/patient openid fhirUser offline_access patient/*.read' }

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

  it 'fails if fhirContext is not an Array' do
    token_response_body =  { fhirContext: 'abc' }.to_json

    result = run(runnable, udap_auth_code_flow_registration_scope:, token_response_body:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/should be an Array/)
  end

  it 'fails if fhirContext contains multiple types' do
    token_response_body =  { fhirContext: ['abc', { reference: '123' }] }.to_json

    result = run(runnable, udap_auth_code_flow_registration_scope:, token_response_body:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Inconsistent `fhirContext` types found/)
  end

  it 'fails if fhirContext contains Patient reference strings' do
    token_response_body =  { fhirContext: ['Patient/abc'] }.to_json

    result = run(runnable, udap_auth_code_flow_registration_scope:, token_response_body:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Patient and Encounter references/)
  end

  it 'fails if fhirContext contains Encounter reference strings' do
    token_response_body =  { fhirContext: ['Encounter/abc'] }.to_json

    result = run(runnable, udap_auth_code_flow_registration_scope:, token_response_body:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Patient and Encounter references/)
  end

  it 'passes if fhirContext contains non-Patient/Encounter reference strings' do
    token_response_body =  { fhirContext: ['Observation/abc', 'Condition/def'] }.to_json

    result = run(runnable, udap_auth_code_flow_registration_scope:, token_response_body:)

    expect(result.result).to eq('pass')
  end

  it 'fails if fhirContext contains non-String/Hash elements' do
    token_response_body =  { fhirContext: [[]] }.to_json

    result = run(runnable, udap_auth_code_flow_registration_scope:, token_response_body:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/elements should be JSON objects, but found/)
  end

  it 'fails if fhirContext contains Patient/Encounter reference objects without a role' do
    token_response_body =  { fhirContext: [{ reference: 'Patient/abc' }] }.to_json

    result = run(runnable, udap_auth_code_flow_registration_scope:, token_response_body:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/are not allowed unless they have a role/)
  end

  it 'fails if fhirContext contains Patient/Encounter reference objects with a "launch" role' do
    token_response_body =  { fhirContext: [{ reference: 'Patient/abc', role: 'launch' }] }.to_json

    result = run(runnable, udap_auth_code_flow_registration_scope:, token_response_body:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/are not allowed unless they have a role/)
  end

  it 'fails if fhirContext role is an empty string' do
    token_response_body =  { fhirContext: [{ reference: 'Observation/abc', role: '' }] }.to_json

    result = run(runnable, udap_auth_code_flow_registration_scope:, token_response_body:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/SHALL NOT be an empty string/)
  end

  it 'fails if fhirContext does not containt a "reference", "canonical", or "identifier" field' do
    token_response_body =  { fhirContext: [{ role: 'ROLE' }] }.to_json

    result = run(runnable, udap_auth_code_flow_registration_scope:, token_response_body:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/SHALL include at least one of "reference", "canonical", or "identifier"/)
  end

  it 'fails if fhirContext fields are the wrong types' do
    token_response_body =  { fhirContext: [{ role: 1, reference: 2, canonical: 3, identifier: 4, type: 5 }] }.to_json

    result = run(runnable, udap_auth_code_flow_registration_scope:, token_response_body:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to include('The following fields have incorrect types')
    expect(result.result_message).to include('role')
    expect(result.result_message).to include('type')
    expect(result.result_message).to include('identifier')
    expect(result.result_message).to include('canonical')
    expect(result.result_message).to include('reference')
  end

  it 'passes if fhirContext objects are all valid' do
    token_response_body =  { fhirContext: [{ role: 'ROLE', reference: 'Patient/abc' },
                                           { canonical: 'http://example.com' }] }.to_json

    result = run(runnable, udap_auth_code_flow_registration_scope:, token_response_body:)

    expect(result.result).to eq('pass')
  end
end
