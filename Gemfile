source ENV['GEM_SOURCE'] || 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? ENV['PUPPET_VERSION'] : ['>= 3.3']
gem 'metadata-json-lint'
gem 'puppet', puppetversion
gem 'puppet-lint', '>= 1.0.0'
gem 'facter', '>= 1.7.0'

group :test do
  gem 'puppetlabs_spec_helper', '>= 1.2.1'
  gem 'rspec-puppet'
  gem 'rspec-puppet-facts', :require => false
end

group :system_tests do
  gem 'beaker-rspec'
end

# rspec must be v2 for ruby 1.8.7
if RUBY_VERSION >= '1.8.7' && RUBY_VERSION < '1.9'
  gem 'rspec', '~> 2.0'
  gem 'rake', '~> 10.0'
else
  # rubocop requires ruby >= 1.9
  gem 'rubocop'
end
