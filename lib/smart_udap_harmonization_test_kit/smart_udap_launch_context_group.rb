require_relative 'smart_udap_encounter_context_test'
require_relative 'smart_udap_fhir_context_test'
require_relative 'smart_udap_intent_context_test'
require_relative 'smart_udap_need_patient_banner_context_test'
require_relative 'smart_udap_patient_context_test'
require_relative 'smart_udap_smart_style_url_context_test'
require_relative 'smart_udap_tenant_context_test'
require_relative 'smart_udap_openid_connect_group'

module SMART_UDAP_HarmonizationTestKit
  class SMART_UDAP_LaunchContextGroup < Inferno::TestGroup
    title 'SMART/UDAP Launch Context'
    id :smart_udap_launch_context
    description ''

    test from: :smart_udap_patient_context,
         optional: true,
         config: {
           inputs: {
             token_response_body: {
               name: :udap_auth_code_flow_token_exchange_response_body
             }
           }
         }

    test from: :smart_udap_encounter_context,
         optional: true,
         config: {
           inputs: {
             token_response_body: {
               name: :udap_auth_code_flow_token_exchange_response_body
             }
           }
         }

    test from: :smart_udap_fhir_context,
         optional: true,
         config: {
           inputs: {
             token_response_body: {
               name: :udap_auth_code_flow_token_exchange_response_body
             }
           }
         }

    test from: :smart_udap_need_patient_banner_context,
         optional: true,
         config: {
           inputs: {
             token_response_body: {
               name: :udap_auth_code_flow_token_exchange_response_body
             }
           }
         }

    test from: :smart_udap_intent_context,
         optional: true,
         config: {
           inputs: {
             token_response_body: {
               name: :udap_auth_code_flow_token_exchange_response_body
             }
           }
         }

    test from: :smart_udap_smart_style_url_context,
         optional: true,
         config: {
           inputs: {
             token_response_body: {
               name: :udap_auth_code_flow_token_exchange_response_body
             }
           }
         }

    test from: :smart_udap_tenant_context,
         optional: true,
         config: {
           inputs: {
             token_response_body: {
               name: :udap_auth_code_flow_token_exchange_response_body
             }
           }
         }
  end
end
