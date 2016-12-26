require 'spec_helper'
require 'puppet'

describe Puppet::Type.type(:postconf_master) do
  subject do
    described_class.new(title: pcm_name,
                        command: pcm_service)
  end

  let(:pcm_service) { 'submission' }
  let(:pcm_type) { :inet }
  let(:pcm_name) { "#{pcm_service}/#{pcm_type}" }
  let(:pcm_line) { "#{pcm_service} #{pcm_type} - - - - - #{pcm_service}" }

  describe 'service =>' do
    it 'accepts common service names' do
      expect do
        described_class.new(title: pcm_name, service: pcm_service, command: pcm_service)
      end.not_to raise_error
    end

    it 'rejects funny service names' do
      expect do
        described_class.new(title: pcm_name, service: 'v3ry funny #name', command: pcm_service)
      end.to raise_error(Puppet::Error, %r{Invalid service})
    end

    it 'is parsed from the title' do
      expect(described_class.new(title: pcm_name, command: pcm_service)[:service]).to eq pcm_service
    end
  end

  describe 'type =>' do
    [:inet, :unix, :fifo, :pipe].each do |t|
      it "accepts #{t}" do
        expect do
          described_class.new(title: pcm_name, type: t, command: pcm_service)
        end.not_to raise_error
      end
    end

    it 'rejects foobar' do
      expect do
        described_class.new(title: pcm_name, type: 'foobar', command: pcm_service)
      end.to raise_error(Puppet::Error, %r{Invalid value})
    end

    it 'is parsed from the title' do
      expect(described_class.new(title: pcm_name, command: pcm_service)[:type]).to eq pcm_type
    end
  end

  describe 'private =>' do
    [:true, :false, :undef, :y, :n].each do |priv|
      it "accepts #{priv}" do
        expect do
          described_class.new(title: pcm_name, private: priv, command: pcm_service)
        end.not_to raise_error
      end
    end

    it 'rejects yolo' do
      expect do
        described_class.new(title: pcm_name, private: 'yolo', command: pcm_service)
      end.to raise_error(Puppet::Error, %r{Invalid value})
    end

    it 'defaults to undef' do
      expect(described_class.new(title: pcm_name, command: pcm_service)[:private]).to eq '-'
    end

    [:true, :y].each do |priv|
      it "#{priv} returns y" do
        expect(described_class.new(title: pcm_name, private: priv, command: pcm_service)[:private]).to eq 'y'
      end
    end

    [:false, :n].each do |priv|
      it "#{priv} returns n" do
        expect(described_class.new(title: pcm_name, private: priv, command: pcm_service)[:private]).to eq 'n'
      end
    end
  end

  describe 'unprivileged =>' do
    [:true, :false, :undef, :y, :n].each do |priv|
      it "accepts #{priv}" do
        expect do
          described_class.new(title: pcm_name, unprivileged: priv, command: pcm_service)
        end.not_to raise_error
      end
    end

    it 'rejects yolo' do
      expect do
        described_class.new(title: pcm_name, unprivileged: 'yolo', command: pcm_service)
      end.to raise_error(Puppet::Error, %r{Invalid value})
    end

    it 'defaults to undef' do
      expect(described_class.new(title: pcm_name, command: pcm_service)[:unprivileged]).to eq '-'
    end

    [:true, :y].each do |priv|
      it "#{priv} returns y" do
        expect(described_class.new(title: pcm_name, unprivileged: priv, command: pcm_service)[:unprivileged]).to eq 'y'
      end
    end

    [:false, :n].each do |priv|
      it "#{priv} returns n" do
        expect(described_class.new(title: pcm_name, unprivileged: priv, command: pcm_service)[:unprivileged]).to eq 'n'
      end
    end
  end

  describe 'chroot =>' do
    [:true, :false, :undef, :y, :n].each do |chroot|
      it "accepts #{chroot}" do
        expect do
          described_class.new(title: pcm_name, chroot: chroot, command: pcm_service)
        end.not_to raise_error
      end
    end

    it 'rejects yolo' do
      expect do
        described_class.new(title: pcm_name, chroot: 'yolo', command: pcm_service)
      end.to raise_error(Puppet::Error, %r{Invalid value})
    end

    it 'defaults to undef' do
      expect(described_class.new(title: pcm_name, command: pcm_service)[:chroot]).to eq '-'
    end

    [:true, :y].each do |chroot|
      it "#{chroot} returns y" do
        expect(described_class.new(title: pcm_name, chroot: chroot, command: pcm_service)[:chroot]).to eq 'y'
      end
    end

    [:false, :n].each do |chroot|
      it "#{chroot} returns n" do
        expect(described_class.new(title: pcm_name, chroot: chroot, command: pcm_service)[:chroot]).to eq 'n'
      end
    end
  end

  describe 'wakeup =>' do
    [:undef, 0, 10, 200, '1', '11', '201', '100?'].each do |wakeup|
      it "accepts #{wakeup}" do
        expect do
          described_class.new(title: pcm_name, wakeup: wakeup, command: pcm_service)
        end.not_to raise_error
      end
    end

    it 'rejects ?10' do
      expect do
        described_class.new(title: pcm_name, wakeup: '?10', command: pcm_service)
      end.to raise_error(Puppet::Error, %r{Invalid value})
    end

    it 'defaults to undef' do
      expect(described_class.new(title: pcm_name, command: pcm_service)[:wakeup]).to eq '-'
    end
  end

  describe 'process_limit =>' do
    [:undef, 0, 10, 200, '1', '11', '201'].each do |process_limit|
      it "accepts #{process_limit}" do
        expect do
          described_class.new(title: pcm_name, process_limit: process_limit, command: pcm_service)
        end.not_to raise_error
      end
    end

    it 'rejects yolo' do
      expect do
        described_class.new(title: pcm_name, process_limit: 'yolo', command: pcm_service)
      end.to raise_error(Puppet::Error, %r{Invalid value})
    end

    it 'defaults to undef' do
      expect(described_class.new(title: pcm_name, command: pcm_service)[:process_limit]).to eq '-'
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

  describe '.full_line' do
    it 'returns the full line syntax as in master.cf' do
      expect(subject.full_line).to eq 'submission inet - - - - - submission'
    end
  end
end
