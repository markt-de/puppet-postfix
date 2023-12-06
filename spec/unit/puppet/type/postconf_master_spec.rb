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

  describe 'service_name =>' do
    it 'accepts common service names' do
      expect {
        described_class.new(title: pcm_name, command: pcm_service)
      }.not_to raise_error
    end

    it 'rejects funny service names' do
      expect {
        described_class.new(title: "v3ry funny #name/#{pcm_type}", command: pcm_service)
      }.to raise_error(Puppet::Error, %r{Invalid value})
    end

    it 'is parsed from the title' do
      expect(described_class.new(title: pcm_name, command: pcm_service).service_name).to eq pcm_service
    end
  end

  describe 'service_type =>' do
    [:inet, :unix, :fifo, :pipe, 'unix-dgram'].each do |t|
      it "accepts #{t}" do
        expect {
          described_class.new(title: "#{pcm_service}/#{t}", command: pcm_service)
        }.not_to raise_error
      end
    end

    it 'rejects foobar' do
      expect {
        described_class.new(title: "#{pcm_service}/foobar", command: pcm_service)
      }.to raise_error(Puppet::Error, %r{Invalid value})
    end

    it 'is parsed from the title' do
      expect(described_class.new(title: pcm_name, command: pcm_service).service_type).to eq pcm_type
    end
  end

  describe 'private =>' do
    [true, false, :true, :false, 'true', 'false', :undef, :y, 'y', :n, 'n', '-'].each do |priv|
      it "accepts #{priv}" do
        expect {
          described_class.new(title: pcm_name, private: priv, command: pcm_service)
        }.not_to raise_error
      end
    end

    it 'rejects yolo' do
      expect {
        described_class.new(title: pcm_name, private: 'yolo', command: pcm_service)
      }.to raise_error(Puppet::Error, %r{Invalid value})
    end

    it 'defaults to undef' do
      expect(described_class.new(title: pcm_name, command: pcm_service)[:private]).to eq '-'
    end

    [true, :true, 'true', :y, 'y'].each do |priv|
      it "#{priv} returns y" do
        expect(described_class.new(title: pcm_name, private: priv, command: pcm_service)[:private]).to eq 'y'
      end
    end

    [false, :false, 'false', :n, 'n'].each do |priv|
      it "#{priv} returns n" do
        expect(described_class.new(title: pcm_name, private: priv, command: pcm_service)[:private]).to eq 'n'
      end
    end
  end
  # rubocop:enable Lint/BooleanSymbol

  # rubocop:disable Lint/BooleanSymbol
  describe 'unprivileged =>' do
    [true, false, :true, :false, 'true', 'false', :undef, :y, 'y', :n, 'n', '-'].each do |unpriv|
      it "accepts #{unpriv}" do
        expect {
          described_class.new(title: pcm_name, unprivileged: unpriv, command: pcm_service)
        }.not_to raise_error
      end
    end

    it 'rejects yolo' do
      expect {
        described_class.new(title: pcm_name, unprivileged: 'yolo', command: pcm_service)
      }.to raise_error(Puppet::Error, %r{Invalid value})
    end

    it 'defaults to undef' do
      expect(described_class.new(title: pcm_name, command: pcm_service)[:unprivileged]).to eq '-'
    end

    [true, :true, 'true', :y, 'y'].each do |unpriv|
      it "#{unpriv} returns y" do
        expect(described_class.new(title: pcm_name, unprivileged: unpriv, command: pcm_service)[:unprivileged]).to eq 'y'
      end
    end

    [false, :false, 'false', :n, 'n'].each do |unpriv|
      it "#{unpriv} returns n" do
        expect(described_class.new(title: pcm_name, unprivileged: unpriv, command: pcm_service)[:unprivileged]).to eq 'n'
      end
    end
  end
  # rubocop:enable Lint/BooleanSymbol

  # rubocop:disable Lint/BooleanSymbol
  describe 'chroot =>' do
    [true, false, :true, :false, 'true', 'false', :undef, :y, 'y', :n, 'n', '-'].each do |chroot|
      it "accepts #{chroot}" do
        expect {
          described_class.new(title: pcm_name, chroot: chroot, command: pcm_service)
        }.not_to raise_error
      end
    end

    it 'rejects yolo' do
      expect {
        described_class.new(title: pcm_name, chroot: 'yolo', command: pcm_service)
      }.to raise_error(Puppet::Error, %r{Invalid value})
    end

    it 'defaults to undef' do
      expect(described_class.new(title: pcm_name, command: pcm_service)[:chroot]).to eq '-'
    end

    [true, :true, 'true', :y, 'y'].each do |chroot|
      it "#{chroot} returns y" do
        expect(described_class.new(title: pcm_name, chroot: chroot, command: pcm_service)[:chroot]).to eq 'y'
      end
    end

    [false, :false, 'false', :n, 'n'].each do |chroot|
      it "#{chroot} returns n" do
        expect(described_class.new(title: pcm_name, chroot: chroot, command: pcm_service)[:chroot]).to eq 'n'
      end
    end
  end
  # rubocop:enable Lint/BooleanSymbol

  describe 'wakeup =>' do
    [:undef, 0, 10, 200, '1', '11', '201', '100?'].each do |wakeup|
      it "accepts #{wakeup}" do
        expect {
          described_class.new(title: pcm_name, wakeup: wakeup, command: pcm_service)
        }.not_to raise_error
      end
    end

    it 'rejects ?10' do
      expect {
        described_class.new(title: pcm_name, wakeup: '?10', command: pcm_service)
      }.to raise_error(Puppet::Error, %r{Invalid value})
    end

    it 'defaults to undef' do
      expect(described_class.new(title: pcm_name, command: pcm_service)[:wakeup]).to eq '-'
    end
  end

  describe 'process_limit =>' do
    [:undef, 0, 10, 200, '1', '11', '201'].each do |process_limit|
      it "accepts #{process_limit}" do
        expect {
          described_class.new(title: pcm_name, process_limit: process_limit, command: pcm_service)
        }.not_to raise_error
      end
    end

    it 'rejects yolo' do
      expect {
        described_class.new(title: pcm_name, process_limit: 'yolo', command: pcm_service)
      }.to raise_error(Puppet::Error, %r{Invalid value})
    end

    it 'defaults to undef' do
      expect(described_class.new(title: pcm_name, command: pcm_service)[:process_limit]).to eq '-'
    end
  end

  describe 'command =>' do
    [
      'smtp',
      'smtpd -o syslog_name=postfix/submissionsmtpd -o syslog_name=postfix/submission',
      'pipe flags=FR user=list argv=/usr/lib/mailman/bin/postfix-to-mailman.py ${nexthop} ${user}pipe flags=FR user=list argv=/usr/lib/mailman/bin/postfix-to-mailman.py ${nexthop} ${user}',
    ].each do |command|
      it "accepts #{command}" do
        expect {
          described_class.new(title: pcm_name, command: command)
        }.not_to raise_error
      end
    end

    it 'is a ignored on ensure => absent' do
      expect {
        described_class.new(title: pcm_name, ensure: :absent)
      }.not_to raise_error
    end
  end
end
