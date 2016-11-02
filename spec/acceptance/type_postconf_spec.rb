require 'spec_helper_acceptance'

describe 'type postconf' do
  let(:manifest) {
    <<-EOS
      postconf { 'myhostname':
        value => 'foo.bar',
      }
    EOS
  }

  it 'should run without errors' do
    result = apply_manifest(manifest, :catch_failures => true)
    expect(@result.exit_code).to eq 2
  end

  it 'should set the myhostname value' do
    apply_manifest(manifest, :catch_failures => true)
    shell('postconf myhostname') do |r|
       expect(r.stdout).to match(/myhostname += +foo.bar/)
    end
  end

  it 'should run a second time without changes' do
    result = apply_manifest(manifest, catch_changes: true)
    expect(@result.exit_code).to eq 0
  end

  describe 'use a different config directory' do
    let(:manifest) {
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
    }

    it 'should run without errors' do
      result = apply_manifest(manifest, :catch_failures => true)
      expect(@result.exit_code).to eq 2
    end
  
    it 'should set the myhostname value' do
      apply_manifest(manifest, :catch_failures => true)
      shell('postconf -c /tmp/postfix-foo myhostname') do |r|
         expect(r.stdout).to match(/myhostname += +foo.bar/)
      end
    end
  
    it 'should run a second time without changes' do
      result = apply_manifest(manifest, :catch_failures => true)
      expect(@result.exit_code).to eq 0
    end

  end
end
