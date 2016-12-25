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
      provider: described_class.name
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
      '-               -               y         /etc/postfix'
    ]
  end

  let(:postconf_F) do
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
      'maildrop/unix/command = pipe flags=DRhu user=vmail argv=/usr/bin/maildrop -d ${recipient}'
    ]
  end

  before do
    described_class.stubs(:postmulti_cmd).with('-l').returns(postmulti_n.join("\n"))
    described_class.stubs(:postconf_cmd).with('-F').returns(postconf_F.join("\n"))
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

    context 'unset parameter' do
      let(:param_name) { 'foobar/unix' }

      it 'does not prefetch a value' do
        described_class.prefetch(param_name => resource)
        expect(resource.provider.command).to eq(:absent)
      end
    end
  end

  describe 'when creating a postconf resource' do
    it 'calls postconf to set the value' do
      provider.expects(:postconf_cmd).with('-M', "#{param_name}=#{param_line}")
      provider.create
    end
  end

  describe 'when deleting a postconf master resource' do
    it 'calls postconf to unset the master entry' do
      provider.expects(:postconf_cmd).with('-MX', param_name)
      provider.destroy
    end
  end

  describe 'when updating the private' do
    it 'calls postconf to update the private field' do
      provider.expects(:postconf_cmd).with('-F', "#{param_name}/private=foobar")
      provider.private = 'foobar'
    end
  end

  describe 'when updating the unprivileged' do
    it 'calls postconf to update the unprivileged field' do
      provider.expects(:postconf_cmd).with('-F', "#{param_name}/unprivileged=foobar")
      provider.unprivileged = 'foobar'
    end
  end

  describe 'when updating the chroot' do
    it 'calls postconf to update the chroot field' do
      provider.expects(:postconf_cmd).with('-F', "#{param_name}/chroot=foobar")
      provider.chroot = 'foobar'
    end
  end

  describe 'when updating the wakeup' do
    it 'calls postconf to update the wakeup field' do
      provider.expects(:postconf_cmd).with('-F', "#{param_name}/wakeup=foobar")
      provider.wakeup = 'foobar'
    end
  end

  describe 'when updating the process_limit' do
    it 'calls postconf to update the process_limit field' do
      provider.expects(:postconf_cmd).with('-F', "#{param_name}/process_limit=foobar")
      provider.process_limit = 'foobar'
    end
  end

  context 'multiple postfix instances' do
    let(:params) do
      {
        title:    param_name,
        command:  param_command,
        chroot:   true,
        config_dir: '/etc/postfix-foobar',
        provider: described_class.name
      }
    end

    let(:postmulti_n) do
      [
        '-               -               y         /etc/postfix',
        'postfix-foobar  -               n         /etc/postfix-foobar'
      ]
    end

    let(:postconf_foobar_F) do
      [
        'smtp/inet/service = smtp',
        'smtp/inet/type = inet',
        'smtp/inet/private = n',
        'smtp/inet/unprivileged = -',
        'smtp/inet/chroot = y',
        'smtp/inet/wakeup = -',
        'smtp/inet/process_limit = -',
        'smtp/inet/command = smtpd'
      ]
    end

    before do
      described_class.stubs(:postmulti_cmd).with('-l').returns(postmulti_n.join("\n"))
      described_class.stubs(:postconf_cmd).with('-F', '-c', '/etc/postfix-foobar').returns(postconf_foobar_F.join("\n"))
      described_class.stubs(:postconf_cmd).with('-F').returns(postconf_F.join("\n"))
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
        provider.expects(:postconf_cmd).with('-M', '-c', '/etc/postfix-foobar', "#{param_name}=#{param_line}")
        provider.create
      end
    end

    describe 'when deleting a postconf master resource' do
      it 'calls postconf to unset the master entry' do
        provider.expects(:postconf_cmd).with('-MX', '-c', '/etc/postfix-foobar', param_name)
        provider.destroy
      end
    end
  end
end
