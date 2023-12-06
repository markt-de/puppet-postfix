require 'spec_helper'

describe Puppet::Type.type(:postconf_master).provider(:postconf) do
  let(:param_service) { 'smtp' }
  let(:param_type) { :inet }
  let(:param_name) { "#{param_service}/#{param_type}" }
  let(:param_command) { 'smtpd' }
  let(:param_line) { "#{param_service} #{param_type} - - y - - #{param_command}" }

  let(:params) do
    {
      title:    param_name,
      command:  param_command,
      chroot:   true,
      provider: described_class.name,
    }
  end

  let(:resource) do
    Puppet::Type.type(:postconf_master).new(params)
  end

  let(:provider) do
    resource.provider
  end

  let(:postmulti_n) do
    [
      '-               -               y         /etc/postfix',
    ]
  end

  let(:postconf_F) do # rubocop:disable all
    [
      'smtp/inet/service = smtp',
      'smtp/inet/type = inet',
      'smtp/inet/private = n',
      'smtp/inet/unprivileged = -',
      'smtp/inet/chroot = y',
      'smtp/inet/wakeup = -',
      'smtp/inet/process_limit = -',
      'smtp/inet/command = smtpd',
      'tlsmgr/unix/service = tlsmgr',
      'tlsmgr/unix/type = unix',
      'tlsmgr/unix/private = -',
      'tlsmgr/unix/unprivileged = -',
      'tlsmgr/unix/chroot = y',
      'tlsmgr/unix/wakeup = 1000?',
      'tlsmgr/unix/process_limit = 1',
      'tlsmgr/unix/command = tlsmgr',
      'maildrop/unix/service = maildrop',
      'maildrop/unix/type = unix',
      'maildrop/unix/private = -',
      'maildrop/unix/unprivileged = n',
      'maildrop/unix/chroot = n',
      'maildrop/unix/wakeup = -',
      'maildrop/unix/process_limit = -',
      'maildrop/unix/command = pipe flags=DRhu user=vmail argv=/usr/bin/maildrop -d ${recipient}',
      'postlog/unix-dgram/service = postlog',
      'postlog/unix-dgram/type = unix-dgram',
      'postlog/unix-dgram/private = n',
      'postlog/unix-dgram/unprivileged = -',
      'postlog/unix-dgram/chroot = n',
      'postlog/unix-dgram/wakeup = -',
      'postlog/unix-dgram/process_limit = 1',
      'postlog/unix-dgram/command = postlogd',
    ]
  end

  before(:each) do
    allow(described_class).to receive(:postmulti_cmd).with('-l').and_return(postmulti_n.join("\n"))
    allow(described_class).to receive(:postconf_cmd).with('-F').and_return(postconf_F.join("\n"))
  end

  describe 'instances' do
    it 'has an instance method' do
      expect(described_class).to respond_to :instances
    end

    it 'prefetches the values' do
      expect(described_class.instances.size).to eq(postconf_F.size / 8)
    end
  end

  describe 'prefetch' do
    it 'has a prefetch method' do
      expect(described_class).to respond_to :prefetch
    end

    it 'correctliy prefetch string values.' do
      described_class.prefetch(param_name => resource)
      expect(resource.provider.command).to eq(param_command)
    end

    context 'with unset parameter' do
      let(:param_name) { 'foobar/unix' }

      it 'does not prefetch a value' do
        described_class.prefetch(param_name => resource)
        expect(resource.provider.command).to eq(:absent)
      end
    end
  end

  describe 'when creating a postconf resource' do
    it 'calls postconf to set the value' do
      expect(provider.class).to receive(:postconf_cmd).with('-M', "#{param_name}=#{param_line}")
      provider.create
      provider.flush
    end
  end

  context 'with missing command' do
    let(:params) do
      {
        title:    param_name,
        chroot:   true,
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
        title:    "postfix-foobar::#{param_name}",
        command:  param_command,
        chroot:   true,
        provider: described_class.name,
      }
    end

    let(:postmulti_n) do
      [
        '-               -               y         /etc/postfix',
        'postfix-foobar  -               n         /etc/postfix-foobar',
      ]
    end

    let(:postconf_foobar_F) do # rubocop:disable all
      [
        'smtp/inet/service = smtp',
        'smtp/inet/type = inet',
        'smtp/inet/private = n',
        'smtp/inet/unprivileged = -',
        'smtp/inet/chroot = y',
        'smtp/inet/wakeup = -',
        'smtp/inet/process_limit = -',
        'smtp/inet/command = smtpd',
      ]
    end

    before(:each) do
      allow(described_class).to receive(:postmulti_cmd).with('-l').and_return(postmulti_n.join("\n"))
      allow(described_class).to receive(:postconf_cmd).with('-c', '/etc/postfix-foobar', '-F').and_return(postconf_foobar_F.join("\n"))
      allow(described_class).to receive(:postconf_cmd).with('-F').and_return(postconf_F.join("\n"))
    end

    describe 'instances' do
      it 'has an instance method' do
        expect(described_class).to respond_to :instances
      end

      it 'prefetches the values' do
        expect(described_class.instances.size).to eq((postconf_F.size + postconf_foobar_F.size) / 8)
      end
    end

    describe 'when creating a postconf resource' do
      it 'calls postconf to set the value' do
        expect(provider.class).to receive(:postconf_cmd).with('-c', '/etc/postfix-foobar', '-M', "#{param_name}=#{param_line}")
        provider.create
        provider.flush
      end
    end

    describe 'when deleting a postconf master resource' do
      it 'calls postconf to unset the master entry' do
        expect(provider.class).to receive(:postconf_cmd).with('-c', '/etc/postfix-foobar', '-M', '-X', param_name)
        provider.destroy
        provider.flush
      end
    end
  end
end
