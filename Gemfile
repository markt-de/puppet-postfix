source ENV['GEM_SOURCE'] || 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? ENV['PUPPET_VERSION'] : ['>= 4.9.0']
gem 'puppet', puppetversion
gem 'puppet-lint', '>= 1.0.0'
gem 'facter', '>= 1.7.0'

group :test do
  gem 'puppetlabs_spec_helper', '>= 2.6'
  gem 'rspec-puppet', '~> 2.6'
  gem 'rspec-puppet-facts', require: false
  gem 'metadata-json-lint'
  gem 'json_pure', '<= 2.0.1', require: false if RUBY_VERSION < '2.0.0'
  gem 'coveralls', require: false
  gem 'simplecov-console', require: false
end

group :development do
  gem 'beaker-rspec'
  gem "puppet-blacksmith"
end
