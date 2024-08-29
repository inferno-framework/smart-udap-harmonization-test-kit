module SMART_UDAP_HarmonizationTestKit
  class DiscoveryGroup < Inferno::TestGroup
    title 'Discovery'
    description %(
      SMART App Launch and UDAP each query a unique `.well-known` endpoint to receive server metatdata specific to each
      standard's workflow.
    )
    id :smart_udap_discovery_group

    # For now don't run as group
    group from: :smart_discovery_stu2
    group from: :udap_discovery_group
  end
end
