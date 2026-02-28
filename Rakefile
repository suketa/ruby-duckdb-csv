# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

test_config = lambda do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

Rake::TestTask.new(:test, &test_config)
task default: %i[clobber test]
