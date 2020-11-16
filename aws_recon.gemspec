# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aws_recon/version'

Gem::Specification.new do |spec|
  spec.name          = 'aws_recon'
  spec.version       = AwsRecon::VERSION
  spec.authors       = ['Josh Larsen', 'Darkbit']
  spec.required_ruby_version = '>= 2.5.0'
  spec.summary       = 'A multi-threaded AWS inventory collection cli tool.'
  spec.description   = 'AWS Recon is a command line tool to collect resources from an Amazon Web Services (AWS) account. The tool outputs JSON suitable for processing with other tools.'
  spec.homepage      = 'https://github.com/darkbitio/aws-recon'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-sdk', '~> 3.0'
  spec.add_dependency 'parallel', '~> 1.19'

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'gem-release', '~> 2.1'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'solargraph', '~> 0.39.11'
  spec.add_development_dependency 'rubocop', '~> 0.87.1'
  spec.add_development_dependency 'pry', '~> 0.13.1'
  spec.add_development_dependency 'byebug', '~> 11.1'
end
