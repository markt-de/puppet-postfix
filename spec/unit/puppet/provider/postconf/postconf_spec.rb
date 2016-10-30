require 'spec_helper'

describe Puppet::Type.type(:postconf).provider(:postconf) do

  let(:params) {
    {
      title:    'myhostname',
      value:    'foo.bar',
      provider: described_class.name
    }
  }

  let(:resource) do
    Puppet::Type.type(:postconf).new(params)
  end
  
  let(:provider) do
    resource.provider
  end

  let(:postconf_n) {[
    'alias_database = hash:/etc/aliases',
    'alias_maps = hash:/etc/aliases',
    'append_dot_mydomain = no',
    'biff = no',
    'inet_interfaces = all',
    'inet_protocols = ipv4',
    'mailbox_size_limit = 0',
    'mydestination = $myhostname, berlin.durchmesser.ch, localhost.durchmesser.ch, localhost',
    'relayhost =',
  ]}

  before do
    described_class.stubs(:postconf).with('-n').returns(postconf_n.join("\n"))
  end
  
	describe 'instances' do
		it 'should have an instance method' do
			expect(described_class).to respond_to :instances
		end

    it 'sould prefetch the values' do
      expect(described_class.instances.size).to eq(postconf_n.size)
    end
	end

	describe 'prefetch' do
		it 'should have a prefetch method' do
			expect(described_class).to respond_to :prefetch
		end
	end

  describe 'when creating a postconf resource' do
    it 'should call postconf to set the value' do
      provider.expects(:postconf).with('myhostname=foo.bar')
      provider.create
    end
  end

  describe 'when deleting a postconf resource' do
    it 'should call postconf to unset the parameter' do
      provider.expects(:postconf).with('-X', 'myhostname')
      provider.destroy
    end
  end

end
