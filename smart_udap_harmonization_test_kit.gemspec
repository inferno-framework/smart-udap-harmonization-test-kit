Gem::Specification.new do |spec|
  spec.name          = 'smart_udap_harmonization_test_kit'
  spec.version       = '0.9.0'
  spec.authors       = ['Alisa Wallace', 'Stephen MacVicar']
  spec.email         = ['inferno@groups.mitre.org']
  spec.summary       = 'SMART-UDAP Harmonization Test Kit'
  spec.description   = 'Test Kit for integrating SMART App Launch and UDAP Security IGs'
  spec.homepage      = 'https://github.com/inferno-framework/smart-udap-harmonization-test-kit'
  spec.license       = 'Apache-2.0'
  spec.add_dependency 'inferno_core', '~> 0.5.0'
  spec.add_dependency 'smart_app_launch_test_kit', '~> 0.4.3'
  spec.add_dependency 'udap_security_test_kit', '~> 0.10.0'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.1.2')
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/inferno-framework/smart-udap-harmonization-test-kit'
  spec.files = [
    Dir['lib/**/*.rb'],
    Dir['lib/**/*.json'],
    'LICENSE'
  ].flatten

  spec.require_paths = ['lib']
end
