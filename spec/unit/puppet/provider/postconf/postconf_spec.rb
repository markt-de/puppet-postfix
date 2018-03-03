require 'spec_helper'

describe Puppet::Type.type(:postconf).provider(:postconf) do
  let(:param_name) { 'myhostname' }
  let(:param_value) { 'foo.bar' }

  let(:params) do
    {
      title:    param_name,
      value:    param_value,
      provider: described_class.name,
    }
  end

  let(:resource) do
    Puppet::Type.type(:postconf).new(params)
  end

  let(:provider) do
    resource.provider
  end

  let(:postmulti_n) do
    [
      '-               -               y         /etc/postfix',
    ]
  end

  let(:postconf_n) do
    [
      'alias_database = hash:/etc/aliases',
      'alias_maps = hash:/etc/aliases',
      'append_dot_mydomain = no',
      'myhostname = foo.bar',
      'biff = no',
      'inet_interfaces = all',
      'inet_protocols = ipv4',
      'mailbox_size_limit = 0',
      'mydestination = $myhostname, berlin.durchmesser.ch, localhost.durchmesser.ch, localhost',
      'relayhost =',
    ]
  end

  before(:each) do
    described_class.stubs(:postmulti_cmd).with('-l').returns(postmulti_n.join("\n"))
    described_class.stubs(:postconf_cmd).with('-n').returns(postconf_n.join("\n"))
  end

  describe 'instances' do
    it 'has an instance method' do
      expect(described_class).to respond_to :instances
    end

    it 'prefetches the values' do
      expect(described_class.instances.size).to eq(postconf_n.size)
    end
  end

  describe 'prefetch' do
    it 'has a prefetch method' do
      expect(described_class).to respond_to :prefetch
    end

    it 'correctly prefetches string values' do
      described_class.prefetch(param_name => resource)
      expect(resource.provider.value).to eq(param_value)
    end

    context 'with unset parameter' do
      let(:param_name) { 'myfoobar' }

      it 'does not prefetch a value' do
        described_class.prefetch(param_name => resource)
        expect(resource.provider.value).to eq(:absent)
      end
    end
  end

  describe 'when creating a postconf resource' do
    it 'calls postconf to set the value' do
      provider.class.expects(:postconf_cmd).with('myhostname=foo.bar')
      provider.create
      provider.flush
    end
  end

  describe 'when deleting a postconf resource' do
    it 'calls postconf to unset the parameter' do
      provider.class.expects(:postconf_cmd).with('-X', 'myhostname')
      provider.destroy
      provider.flush
    end
  end

  context 'with array values' do
    let(:params) do
      {
        title:    'myhostname',
        value:    %w[foo bar],
        provider: described_class.name,
      }
    end

    describe 'when creating a postconf resource' do
      it 'calls postconf to set the value' do
        provider.class.expects(:postconf_cmd).with('myhostname=foo, bar')
        provider.create
        provider.flush
      end
    end
  end

  context 'with missing value' do
    let(:params) do
      {
        title:    'myfoobar',
        provider: described_class.name,
      }
    end

    describe 'when creating a postconf resource' do
      it 'raises an error' do
        expect {
          provider.create
          provider.flush
        }.to raise_error(ArgumentError, %r{required})
      end
    end
  end

  context 'with multiple postfix instances' do
    let(:params) do
      {
        title:      'postfix-foobar::myhostname',
        value:      'foo.bar',
        provider:   described_class.name,
      }
    end

    let(:postmulti_n) do
      [
        '-               -               y         /etc/postfix',
        'postfix-foobar  -               n         /etc/postfix-foobar',
      ]
    end

    let(:postconf_foobar_n) do
      [
        'alias_database = hash:/etc/aliases',
        'alias_maps = hash:/etc/aliases',
        'append_dot_mydomain = no',
      ]
    end

    before(:each) do
      described_class.stubs(:postmulti_cmd).with('-l').returns(postmulti_n.join("\n"))
      described_class.stubs(:postconf_cmd).with('-c', '/etc/postfix-foobar', '-n').returns(postconf_foobar_n.join("\n"))
      described_class.stubs(:postconf_cmd).with('-n').returns(postconf_n.join("\n"))
    end

    describe 'instances' do
      it 'prefetches the values from both instances' do
        expect(described_class.instances.size).to eq(postconf_n.size + postconf_foobar_n.size)
      end
    end

    describe 'when creating a postconf resource' do
      it 'calls postconf to set the value' do
        provider.class.expects(:postconf_cmd).with('-c', '/etc/postfix-foobar', 'myhostname=foo.bar')
        provider.create
        provider.flush
      end
    end

    describe 'when deleting a postconf resource' do
      it 'calls postconf to unset the parameter' do
        provider.class.expects(:postconf_cmd).with('-c', '/etc/postfix-foobar', '-X', 'myhostname')
        provider.destroy
        provider.flush
      end
    end
  end
end
