Gem::Specification.new do |spec|
  spec.name          = 'smart_udap_harmonization_test_kit'
  spec.version       = '0.0.1'
  spec.authors       = ['Alisa Wallace']
  spec.email         = ['inferno@groups.mitre.org']
  spec.summary       = 'SMART-UDAP Harmonization Test Kit'
  spec.description   = 'Test Kit for integrating SMART App Launch and UDAP Security IGs'
  # spec.homepage      = 'TODO'
  spec.license       = 'Apache-2.0'
  spec.add_dependency 'inferno_core', '~> 0.4.38'
  spec.add_dependency 'smart_app_launch_test_kit', '~> 0.4.3'
  spec.add_dependency 'udap_security_test_kit', '~> 0.10.0'
  spec.add_development_dependency 'database_cleaner-sequel', '~> 1.8'
  spec.add_development_dependency 'factory_bot', '~> 6.1'
  spec.add_development_dependency 'rack-test', '~> 1.1.0'
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'webmock', '~> 3.11'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.1.2')
  # spec.metadata['homepage_uri'] = spec.homepage
  # spec.metadata['source_code_uri'] = 'TODO'
  spec.files = [
    Dir['lib/**/*.rb'],
    Dir['lib/**/*.json'],
    'LICENSE'
  ].flatten

  spec.require_paths = ['lib']
end
