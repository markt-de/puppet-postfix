require 'spec_helper_acceptance'

describe 'type postconf' do
  let(:manifest) do
    <<-EOS
      postconf { 'myhostname':
        value => 'foo.bar',
      }
    EOS
  end

  it 'runs without errors' do
    apply_manifest(manifest, catch_failures: true)
  end

  it 'sets the myhostname value' do
    apply_manifest(manifest, catch_failures: true)
    shell('postconf myhostname') do |r|
      expect(r.stdout).to match(%r{myhostname += +foo.bar})
    end
  end

  it 'runs a second time without changes' do
    apply_manifest(manifest, catch_changes: true)
  end

  describe 'use a array as value' do
    let(:manifest) do
      <<-EOS
        postconf { 'authorized_flush_users':
          value => ['foo', 'bar'],
        }
      EOS
    end

    it 'runs without errors' do
      apply_manifest(manifest, catch_failures: true)
    end

    it 'sets the myhostname value' do
      apply_manifest(manifest, catch_failures: true)
      shell('postconf authorized_flush_users') do |r|
        expect(r.stdout).to match(%r{authorized_flush_users += +foo[, ]+bar})
      end
    end

    it 'runs a second time without changes' do
      apply_manifest(manifest, catch_changes: true)
    end
  end

  describe 'use a different config directory' do
    let(:manifest) do
      <<-EOS
        file {
          '/tmp/postfix-foo':
            ensure => directory;
          '/tmp/postfix-foo/main.cf':
            content => '',
            replace => false;
        } ->
        postconf { 'myhostname':
          value      => 'foo.bar',
          config_dir => '/tmp/postfix-foo',
        }
      EOS
    end

    it 'runs without errors' do
      apply_manifest(manifest, catch_failures: true)
    end

    it 'sets the myhostname value' do
      apply_manifest(manifest, catch_failures: true)
      shell('postconf -c /tmp/postfix-foo myhostname') do |r|
        expect(r.stdout).to match(%r{myhostname += +foo.bar})
      end
    end

    it 'runs a second time without changes' do
      apply_manifest(manifest, catch_failures: true)
    end
  end
end
