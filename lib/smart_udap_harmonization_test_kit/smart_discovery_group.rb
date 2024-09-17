module SMART_UDAP_HarmonizationTestKit
  class SMARTDiscoveryGroup < Inferno::TestGroup
    title 'SMART Discovery'
    description %(
      Query the `.well-known` endpoint to receive SMART server metatdata.
      Testers should run either STU1 or STU2, not both.
    )
    id :harmonization_smart_discovery_group

    # For now don't run as group
    group from: :smart_discovery_stu1
    group from: :smart_discovery_stu2
  end
end
