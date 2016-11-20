source ENV['GEM_SOURCE'] || 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? ENV['PUPPET_VERSION'] : ['>= 3.3']
gem 'puppet', puppetversion
gem 'puppet-lint', '>= 1.0.0'
gem 'facter', '>= 1.7.0'

group :test do
  gem 'puppetlabs_spec_helper', '>= 1.2.1'
  gem 'rspec-puppet', '~> 2.5'
  gem 'rspec-puppet-facts', require: false
  gem 'metadata-json-lint'
  gem 'rubocop-rspec', '~> 1.6', require: false if RUBY_VERSION >= '2.3.0'
  gem 'json_pure', '<= 2.0.1', require: false if RUBY_VERSION < '2.0.0'
  gem 'coveralls', require: false if RUBY_VERSION >= '2.0.0'
  gem 'simplecov-console', require: false if RUBY_VERSION >= '2.0.0'
end

group :system_tests do
  gem 'beaker-rspec'
end
