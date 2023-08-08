require 'spec_helper'

describe Puppet::Type.type(:postmulti).provider(:postmulti) do
  let(:params) do
    {
      title:    'postfix-foo',
      provider: described_class.name,
    }
  end

  let(:resource) do
    Puppet::Type.type(:postmulti).new(params)
  end

  let(:provider) do
    resource.provider
  end

  let(:postmulti_n) do
    [
      '-               -               y         /etc/postfix',
      'postfix-foo     bar             n         /etc/postfix-foo',
    ]
  end

  before(:each) do
    allow(described_class).to receive(:postmulti_cmd).with('-l').and_return(postmulti_n.join("\n"))
  end

  describe 'instances' do
    it 'has an instance method' do
      expect(described_class).to respond_to :instances
    end

    it 'prefetches the values' do
      expect(described_class.instances.size).to eq(postmulti_n.size - 1)
    end
  end

  describe 'prefetch' do
    it 'has a prefetch method' do
      expect(described_class).to respond_to :prefetch
    end
  end

  describe 'when creating a postconf resource' do
    it 'calls postmulti to create the instance' do
      expect(provider.class).to receive(:postmulti_cmd).with('-e', 'create', '-I', 'postfix-foo')
      provider.create
    end

    context 'with a group' do
      let(:params) do
        {
          title:    'postfix-foo',
          group:    'bar',
          provider: described_class.name,
        }
      end

      it 'calls postmulti to create the instance' do
        expect(provider.class).to receive(:postmulti_cmd).with('-e', 'create', '-I', 'postfix-foo', '-G', 'bar')
        provider.create
      end
    end
  end

  describe 'when activating a postconf resource' do
    it 'calls postmulti to activate the instance' do
      allow(provider.class).to receive(:postmulti_cmd).with('-e', 'create', '-I', 'postfix-foo')
      expect(provider.class).to receive(:postmulti_cmd).with('-e', 'enable', '-i', 'postfix-foo')
      provider.activate
    end
  end

  describe 'when deactivating a postconf resource' do
    it 'calls postmulti to activate the instance' do
      allow(provider.class).to receive(:postmulti_cmd).with('-e', 'create', '-I', 'postfix-foo')
      expect(provider.class).to receive(:postmulti_cmd).with('-e', 'disable', '-i', 'postfix-foo')
      provider.deactivate
    end
  end

  describe 'when deleting a postconf resource' do
    it 'calls postconf to unset the parameter' do
      expect(provider.class).to receive(:postmulti_cmd).with('-e', 'destroy', '-i', 'postfix-foo')
      provider.destroy
    end
  end

  describe 'when updating the group' do
    it 'calls postconf to update the group' do
      expect(provider.class).to receive(:postmulti_cmd).with('-e', 'assign', '-i', 'postfix-foo', '-G', 'bar')
      provider.group = 'bar'
    end
  end
end
