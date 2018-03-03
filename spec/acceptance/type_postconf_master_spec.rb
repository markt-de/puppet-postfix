require 'spec_helper_acceptance'

describe 'type postconf_master' do
  let(:manifest) do
    <<-MANIFEST
      postconf_master { 'rspec/unix':
        ensure  => present,
        command => 'foobar',
      }
    MANIFEST
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
      <<-MANIFEST
        postconf_master { 'rspec/unix':
          ensure  => present,
          command => 'foobar',
          chroot  => true,
        }
      MANIFEST
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
end
