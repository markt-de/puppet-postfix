require 'spec_helper_acceptance'

describe 'class ::postfix' do
  let(:manifest) do
    <<-MANIFEST
      include postfix
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
