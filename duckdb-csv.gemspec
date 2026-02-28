# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'duckdb/csv/version'

Gem::Specification.new do |spec|
  spec.name          = 'duckdb-csv'
  spec.version       = DuckDB::CSV::VERSION
  spec.authors       = ['Masaki Suketa']
  spec.email         = ['masaki.suketa@nifty.ne.jp']

  spec.summary       = 'This module provides CSV table adapter for duckdb.'
  spec.description   = 'This module provides CSV table adapter for duckdb. ' \
                       'You can access CSV like as duckdb table by using this module.'
  spec.homepage      = 'https://github.com/suketa/ruby-duckdb-csv'
  spec.license       = 'MIT'

  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/suketa/ruby-duckdb-csv'
  spec.metadata['changelog_uri'] = 'https://github.com/suketa/ruby-duckdb-csv/blob/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 3.2.0'
  spec.add_dependency 'csv'
  spec.add_dependency 'duckdb', '>= 1.4.4.0'
end
