require 'spec_helper_acceptance'

describe 'type multi' do
  let(:manifest) do
    <<-MANIFEST
      postmulti { 'postfix-foo':
        group => 'bar'
      }
    MANIFEST
  end

  it 'runs without errors' do
    apply_manifest(manifest, catch_failures: true)
  end

  it 'creates the instance' do
    run_shell('postmulti -l') do |r|
      expect(r.stdout).to match(%r{^postfix-foo})
    end
  end

  it 'runs a second time without changes' do
    apply_manifest(manifest, catch_changes: true)
  end
end
