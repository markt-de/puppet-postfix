require 'spec_helper_acceptance'

describe 'class ::postfix' do
  let(:manifest) do
    <<-MANIFEST
      # Postfix is very strict with regard to it's listen addresses
      # and interfaces. A nonexistent entry will cause a fatal error,
      # rendering the provider nonfunctional.
      # Apparently some test containers actually have a broken network
      # configuration, e.g. they refer to ::1 for localhost, but it is
      # not configured on any interface. Below file_line resources
      # will handle this issue.
      file_line { 'ensure only ip6-localhost is present':
        line   => '::1 ip6-localhost ip6-loopback',
        path   => '/etc/hosts',
        match  => '^::1',
      }
      -> file_line { 'ensure IPv4 localhost is present':
        line   => '127.0.0.1  localhost',
        path   => '/etc/hosts',
        match  => '^127.0.0.1',
      }
      -> class { 'postfix':
        main_config => {
          inet_interfaces => 'loopback-only',
          inet_protocols  => 'ipv4',
        },
      }
    MANIFEST
  end

  it 'runs without errors' do
    apply_manifest(manifest, catch_failures: true)
  end

  it 'runs a second time without changes' do
    apply_manifest(manifest, catch_changes: true)
  end

  describe package('postfix') do
    it { is_expected.to be_installed }
  end
end
