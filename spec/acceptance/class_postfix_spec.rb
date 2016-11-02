require 'spec_helper_acceptance'

describe 'class ::postfix' do
  let(:manifest) {
    <<-EOS
      include postfix
    EOS
  }

  it 'should run without errors' do
    result = apply_manifest(manifest, :catch_failures => true)
    expect(@result.exit_code).to eq 2
  end

  it 'should run a second time without changes' do
    result = apply_manifest(manifest, :catch_failures => true)
    expect(@result.exit_code).to eq 0
  end

  describe package('postfix') do
    it { is_expected.to be_installed }
  end
end
