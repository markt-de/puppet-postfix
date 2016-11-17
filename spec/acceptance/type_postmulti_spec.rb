require 'spec_helper_acceptance'

describe 'type multi' do
  let(:manifest) {
    <<-EOS
      postmulti { 'postfix-foo':
        group => 'bar'
      }
    EOS
  }

  it 'should run without errors' do
    apply_manifest(manifest, :catch_failures => true)
  end

  it 'should create the instance' do
    shell('postmulti -l') do |r|
       expect(r.stdout).to match(/^postfix-foo/)
    end
  end

  it 'should run a second time without changes' do
    apply_manifest(manifest, catch_changes: true)
  end

end
