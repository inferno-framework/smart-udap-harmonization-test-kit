require_relative 'lib/smart_udap_harmonization_test_kit/version'

Gem::Specification.new do |spec|
  spec.name          = 'smart_udap_harmonization_test_kit'
  spec.version       = SMART_UDAP_HarmonizationTestKit::VERSION
  spec.authors       = ['Alisa Wallace', 'Stephen MacVicar']
  spec.summary       = 'SMART-UDAP Harmonization Test Kit'
  spec.description   = 'Test Kit for integrating SMART App Launch and UDAP Security IGs'
  spec.homepage      = 'https://github.com/inferno-framework/smart-udap-harmonization-test-kit'
  spec.license       = 'Apache-2.0'
  spec.add_runtime_dependency 'inferno_core', '~> 1.0', '>= 1.0.2'
  spec.add_dependency 'smart_app_launch_test_kit', '~> 1.0'
  spec.add_dependency 'udap_security_test_kit', '~> 0.12.0'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.1.2')
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/inferno-framework/smart-udap-harmonization-test-kit'
  spec.metadata['inferno_test_kit'] = 'true'
  spec.files         = `[ -d .git ] && git ls-files -z lib config/presets LICENSE`.split("\x0")

  spec.require_paths = ['lib']
end
