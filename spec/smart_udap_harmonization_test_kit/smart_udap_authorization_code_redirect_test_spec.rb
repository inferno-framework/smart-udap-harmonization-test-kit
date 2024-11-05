require_relative '../../lib/smart_udap_harmonization_test_kit/smart_udap_authorization_code_redirect_test'
require_relative '../request_helper'

RSpec.describe SMART_UDAP_HarmonizationTestKit::SMART_UDAP_AuthorizationCodeRedirectTest do
  include Rack::Test::Methods
  include RequestHelpers

  let(:test) { Inferno::Repositories::Tests.new.find('smart_udap_authorization_code_redirect') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:results_repo) { Inferno::Repositories::Results.new }
  let(:requests_repo) { Inferno::Repositories::Requests.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'smart_udap_harmonization') }
  let(:udap_fhir_base_url) { 'http://example.com/fhir' }
  let(:inputs) do
    {
      udap_fhir_base_url:,
      udap_client_id: 'CLIENT_ID',
      udap_auth_code_flow_registration_scope: 'REQUESTED_SCOPES',
      udap_authorization_endpoint: 'http://example.com/auth'
    }
  end

  def run(runnable, inputs = {})
    test_run_params = { test_session_id: test_session.id }.merge(runnable.reference_hash)
    test_run = Inferno::Repositories::TestRuns.new.create(test_run_params)
    inputs.each do |name, value|
      type = runnable.config.input_type(name)
      type = 'text' if type == 'radio'
      session_data_repo.save(
        test_session_id: test_session.id,
        name:,
        value:,
        type:
      )
    end
    Inferno::TestRunner.new(test_session:, test_run:).run(runnable)
  end

  it 'waits and then passes when it receives a request with the correct state' do
    allow(test).to receive(:parent).and_return(Inferno::TestGroup)
    result = run(test, inputs)
    expect(result.result).to eq('wait')

    state = session_data_repo.load(test_session_id: test_session.id, name: 'udap_authorization_code_state')
    get "/custom/smart_udap_harmonization/redirect?state=#{state}"

    result = results_repo.find(result.id)
    expect(result.result).to eq('pass')
  end

  it 'continues to wait when it receives a request with the incorrect state' do
    result = run(test, inputs)
    expect(result.result).to eq('wait')

    state = SecureRandom.uuid
    get "/custom/smart_udap_harmonization/redirect?state=#{state}"

    result = results_repo.find(result.id)
    expect(result.result).to eq('wait')
  end

  it 'fails if the authorization url is invalid' do
    inputs[:udap_authorization_endpoint] = 'xyz'
    result = run(test, inputs)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/is not a valid URI/)
  end

  it "persists the incoming 'redirect' request" do
    allow(test).to receive(:parent).and_return(Inferno::TestGroup)
    run(test, inputs)
    state = session_data_repo.load(test_session_id: test_session.id, name: 'udap_authorization_code_state')
    url = "/custom/smart_udap_harmonization/redirect?state=#{state}"
    get url

    request = requests_repo.find_named_request(test_session.id, 'redirect')
    expect(request.url).to end_with(url)
  end

  it "persists the 'state' output" do
    result = run(test, inputs)
    expect(result.result).to eq('wait')

    state = result.result_message.match(/a state of `(.*)`/)[1]
    persisted_state = session_data_repo.load(test_session_id: test_session.id, name: 'udap_authorization_code_state')

    expect(persisted_state).to eq(state)
  end
end
