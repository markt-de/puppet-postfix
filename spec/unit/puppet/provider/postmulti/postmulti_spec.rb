require 'spec_helper'

describe Puppet::Type.type(:postmulti).provider(:postmulti) do

  let(:params) {
    {
      title:    'postfix-foo',
      provider: described_class.name
    }
  }

  let(:resource) do
    Puppet::Type.type(:postmulti).new(params)
  end

  let(:provider) do
    resource.provider
  end

  let(:postmulti_n) {[
    '-               -               y         /etc/postfix',
    'postfix-foo     bar             n         /etc/postfix-foo',
  ]}

  before do
    described_class.stubs(:postmulti_cmd).with('-l').returns(postmulti_n.join("\n"))
  end

  describe 'instances' do
    it 'should have an instance method' do
      expect(described_class).to respond_to :instances
    end

    it 'should prefetch the values' do
      expect(described_class.instances.size).to eq(postmulti_n.size-1)
    end
  end

	describe 'prefetch' do
		it 'should have a prefetch method' do
			expect(described_class).to respond_to :prefetch
		end
	end

  describe 'when creating a postconf resource' do
    it 'should call postmulti to create the instance' do
      provider.expects(:postmulti_cmd).with('-e', 'create', '-I', 'postfix-foo')
      provider.create
    end

    context 'with a group' do
			let(:params) {
				{
					title:    'postfix-foo',
          group:    'bar',
					provider: described_class.name
				}
			}

      it 'should call postmulti to create the instance' do
        provider.expects(:postmulti_cmd).with('-e', 'create', '-I', 'postfix-foo', '-G', 'bar')
        provider.create
      end
    end
  end

  describe 'when activating a postconf resource' do
    it 'should call postmulti to activate the instance' do
      provider.expects(:postmulti_cmd).with('-e', 'enable', '-i', 'postfix-foo')
      provider.activate
    end
  end

  describe 'when deactivating a postconf resource' do
    it 'should call postmulti to activate the instance' do
      provider.expects(:postmulti_cmd).with('-e', 'disable', '-i', 'postfix-foo')
      provider.deactivate
    end
  end

  describe 'when deleting a postconf resource' do
    it 'should call postconf to unset the parameter' do
      provider.expects(:postmulti_cmd).with('-e', 'destroy', '-i', 'postfix-foo')
      provider.destroy
    end
  end

  describe 'when updating the group' do
    it 'should call postconf to update the group' do
      provider.expects(:postmulti_cmd).with('-e', 'assign', '-i', 'postfix-foo', '-G', 'bar')
      provider.group = 'bar'
    end
  end

end
