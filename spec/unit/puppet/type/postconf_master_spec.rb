require 'spec_helper'
require 'puppet'

describe Puppet::Type.type(:postconf_master) do
  let(:pcm_service) { 'sumbission' }
  let(:pcm_type) { :inet }
  let(:pcm_name) { "#{pcm_service}/#{pcm_type}" }
  let(:pcm_line) { "#{pcm_service} #{pcm_type} - - y - - #{pcm_service}" }

  describe 'service =>' do
    it 'accepts common service names' do
      expect do
        described_class.new(title: pcm_name, service: pcm_service)
      end.not_to raise_error
    end

    it 'rejects funny service names' do
      expect do
        described_class.new(title: pcm_name, service: 'v3ry funny #name')
      end.to raise_error(Puppet::Error, %r{Invalid service})
    end

    it 'is parsed from the title' do
      expect(described_class.new(title: pcm_name)[:service]).to eq pcm_service
    end
  end

  describe 'type =>' do
    [:inet, :unix, :fifo, :pipe].each do |t|
      it "accepts #{t}" do
        expect do
          described_class.new(title: pcm_name, type: t)
        end.not_to raise_error
      end
    end

    it 'rejects foobar' do
      expect do
        described_class.new(title: pcm_name, type: 'foobar')
      end.to raise_error(Puppet::Error, %r{Invalid value})
    end
  end

  it 'is parsed from the title' do
    expect(described_class.new(title: pcm_name)[:type]).to eq pcm_type
  end

  describe 'private =>' do
    [:true, :false, :undef, :y, :n].each do |priv|
      it "accepts #{priv}" do
        expect do
          described_class.new(title: pcm_name, private: priv)
        end.not_to raise_error
      end
    end

    it 'rejects yolo' do
      expect do
        described_class.new(title: pcm_name, private: 'yolo')
      end.to raise_error(Puppet::Error, %r{Invalid value})
    end

    it 'defaults to undef' do
      expect(described_class.new(title: pcm_name)[:private]).to eq :undef
    end
  end

  describe 'unprivileged =>' do
    [:true, :false, :undef, :y, :n].each do |priv|
      it "accepts #{priv}" do
        expect do
          described_class.new(title: pcm_name, unprivileged: priv)
        end.not_to raise_error
      end
    end

    it 'rejects yolo' do
      expect do
        described_class.new(title: pcm_name, unprivileged: 'yolo')
      end.to raise_error(Puppet::Error, %r{Invalid value})
    end

    it 'defaults to undef' do
      expect(described_class.new(title: pcm_name)[:unprivileged]).to eq :undef
    end
  end

  describe 'chroot =>' do
    [:true, :false, :undef, :y, :n].each do |chroot|
      it "accepts #{chroot}" do
        expect do
          described_class.new(title: pcm_name, chroot: chroot)
        end.not_to raise_error
      end
    end

    it 'rejects yolo' do
      expect do
        described_class.new(title: pcm_name, chroot: 'yolo')
      end.to raise_error(Puppet::Error, %r{Invalid value})
    end

    it 'defaults to undef' do
      expect(described_class.new(title: pcm_name)[:chroot]).to eq :undef
    end
  end

  describe 'wakeup =>' do
    [:undef, 0, 10, 200, '1', '11', '201', '100?'].each do |wakeup|
      it "accepts #{wakeup}" do
        expect do
          described_class.new(title: pcm_name, wakeup: wakeup)
        end.not_to raise_error
      end
    end

    it 'rejects ?10' do
      expect do
        described_class.new(title: pcm_name, wakeup: '?10')
      end.to raise_error(Puppet::Error, %r{Invalid value})
    end

    it 'defaults to undef' do
      expect(described_class.new(title: pcm_name)[:wakeup]).to eq :undef
    end
  end

  describe 'process_limit =>' do
    [:undef, 0, 10, 200, '1', '11', '201'].each do |wakeup|
      it "accepts #{wakeup}" do
        expect do
          described_class.new(title: pcm_name, process_limit: wakeup)
        end.not_to raise_error
      end
    end

    it 'rejects yolo' do
      expect do
        described_class.new(title: pcm_name, process_limit: 'yolo')
      end.to raise_error(Puppet::Error, %r{Invalid value})
    end

    it 'defaults to undef' do
      expect(described_class.new(title: pcm_name)[:process_limit]).to eq :undef
    end
  end

  describe 'command =>' do
    [
      'smtp',
      'smtpd -o syslog_name=postfix/submissionsmtpd -o syslog_name=postfix/submission',
      'pipe flags=FR user=list argv=/usr/lib/mailman/bin/postfix-to-mailman.py ${nexthop} ${user}pipe flags=FR user=list argv=/usr/lib/mailman/bin/postfix-to-mailman.py ${nexthop} ${user}'
    ].each do |command|
      it "accepts #{command}" do
        expect do
          described_class.new(title: pcm_name, command: command)
        end.not_to raise_error
      end
    end

    it 'is a required parameter' do
      expect do
        described_class.new(title: pcm_name, ensure: :present)
      end.to raise_error(RuntimeError, %r{required})
    end

    it 'is a ignored on ensure => absent' do
      expect do
        described_class.new(title: pcm_name, ensure: :absent)
      end.not_to raise_error
    end
  end
end
