require_relative '../../lib/smart_udap_harmonization_test_kit/smart_udap_token_refresh_test'
require_relative '../../lib/smart_udap_harmonization_test_kit/smart_udap_request_builder'
require 'udap_security_test_kit/default_cert_file_loader'

RSpec.describe SMART_UDAP_HarmonizationTestKit::SMART_UDAP_TokenRefreshTest do # rubocop:disable RSpec/SpecFilePathFormat
  let(:suite_id) { :smart_udap_harmonization }
  let(:runnable) { find_test suite, 'smart_udap_token_refresh' }
  let(:udap_auth_code_flow_client_cert_pem) do
    UDAPSecurityTestKit::DefaultCertFileLoader.load_test_client_cert_pem_file
  end

  let(:udap_auth_code_flow_client_private_key) do
    UDAPSecurityTestKit::DefaultCertFileLoader.load_test_client_private_key_file
  end

  let(:base_url) { 'http://example.com/fhir' }
  let(:udap_token_endpoint) { 'http://example.com/token' }
  let(:udap_refresh_token) { 'Example refresh token' }

  let(:input) do
    {
      udap_refresh_token:,
      received_scopes: 'openid fhirUser offline_access patient/*.read',
      udap_token_endpoint:,
      udap_client_id: 'CLIENT_ID',
      udap_auth_code_flow_client_cert_pem:,
      udap_auth_code_flow_client_private_key:,
      udap_jwt_signing_alg: 'RS256'
    }
  end

  it 'skips if refresh token is not present' do
    stub_request(:post, udap_token_endpoint)
      .to_return(status: 200, body: {}.to_json)

    result = run(runnable,
                 udap_refresh_token: '',
                 received_scopes: 'scopes',
                 udap_token_endpoint:,
                 udap_client_id: 'CLIENT_ID',
                 udap_auth_code_flow_client_cert_pem:,
                 udap_auth_code_flow_client_private_key:,
                 udap_jwt_signing_alg: 'RS256')

    expect(result.result).to eq('skip')
  end

  it 'passes if the refresh token exchange response has a 200 status' do
    stub_request(:post, udap_token_endpoint)
      .to_return(status: 200, body: {}.to_json)

    result = run(runnable, input)
    expect(result.result).to eq('pass')
  end

  it 'fails if the refresh token exchange response has a non-200 status' do
    stub_request(:post, udap_token_endpoint)
      .to_return(status: 401, body: {}.to_json)

    result = run(runnable, input)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/expected 200/)
  end
end
