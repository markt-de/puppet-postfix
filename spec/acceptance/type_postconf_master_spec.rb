require 'spec_helper_acceptance'

describe 'type postconf_master' do
  let(:manifest) do
    <<-EOS
      postconf_master { 'rspec/unix':
        ensure  => present,
        command => 'foobar',
      }
    EOS
  end

  it 'runs without errors' do
    apply_manifest(manifest, catch_failures: true)
  end

  it 'creates a new master.cf entry' do
    apply_manifest(manifest, catch_failures: true)
    shell('postconf -M rspec') do |r|
      expect(r.stdout).to match(%r{foobar$})
    end
  end

  it 'runs a second time without changes' do
    apply_manifest(manifest, catch_changes: true)
  end

  describe 'update the chroot' do
    let(:manifest) do
      <<-EOS
        postconf_master { 'rspec/unix':
          ensure  => present,
          command => 'foobar',
          chroot  => true,
        }
      EOS
    end

    it 'runs without errors' do
      apply_manifest(manifest, catch_failures: true)
    end

    it 'creates a new master.cf entry' do
      apply_manifest(manifest, catch_failures: true)
      shell('postconf -M rspec') do |r|
        expect(r.stdout).to match(%r{ +y +- +- +foobar$})
      end
    end

    it 'runs a second time without changes' do
      apply_manifest(manifest, catch_changes: true)
    end
  end

  # describe 'use a different config directory' do
  #   let(:manifest) do
  #     <<-EOS
  #       file {
  #         '/tmp/postfix-foo':
  #           ensure => directory;
  #         '/tmp/postfix-foo/main.cf':
  #           content => '',
  #           replace => false;
  #       } ->
  #       postconf { 'myhostname':
  #         value      => 'foo.bar',
  #         config_dir => '/tmp/postfix-foo',
  #       }
  #     EOS
  #   end

  #   it 'runs without errors' do
  #     apply_manifest(manifest, catch_failures: true)
  #   end

  #   it 'sets the myhostname value' do
  #     apply_manifest(manifest, catch_failures: true)
  #     shell('postconf -c /tmp/postfix-foo myhostname') do |r|
  #       expect(r.stdout).to match(%r{myhostname += +foo.bar})
  #     end
  #   end

  #   it 'runs a second time without changes' do
  #     apply_manifest(manifest, catch_failures: true)
  #   end
  # end
end
