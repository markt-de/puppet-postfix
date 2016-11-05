require 'spec_helper_acceptance'

describe 'type postconf' do
  let(:manifest) {
    <<-EOS
      postmulti { 'postfix-foo':
        group => 'bar'
      }
    EOS
  }

  it 'should run without errors' do
    @result = apply_manifest(manifest, :catch_failures => true)
    expect(@result.exit_code).to eq 2
  end

  it 'should create the instance' do
    apply_manifest(manifest, :catch_failures => true)
    shell('postmulti -l') do |r|
       expect(r.stdout).to match(/^postfix-foo/)
    end
  end

  it 'should run a second time without changes' do
    @result = apply_manifest(manifest, catch_changes: true)
    expect(@result.exit_code).to eq 0
  end

end
