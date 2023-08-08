require 'spec_helper'
require 'puppet'

describe Puppet::Type.type(:postmulti) do
  let(:name) { 'postfix-foobar' }
  let(:invalid_name) { 'foobar' }

  describe 'namevar' do
    it 'accepts a valid value' do
      expect {
        described_class.new(name: name)
      }.not_to raise_error
    end

    it 'does not accept a invalid name' do
      expect {
        described_class.new(name: invalid_name)
      }.to raise_error(Puppet::Error, %r{Invalid name})
    end
  end

  describe '=> ensure' do
    [:present, :absent, :active, :inactive].each do |value|
      it "supports #{value} as a value to ensure" do
        expect {
          described_class.new(name: name,
                              ensure: value)
        }.not_to raise_error
      end
    end

    it 'does not support other values' do
      expect {
        described_class.new(name: name,
                            ensure: :yolo)
      }.to raise_error(Puppet::Error, %r{Invalid value})
    end

    {
      present: :activate,
      active: :activate,
      inactive: :deactivate,
    }.each do |value, methode|
      it "for #{value} calls #{methode} on the resource" do
        resource = described_class.new(name: name, ensure: value)
        resource.expects(methode)
        resource.property(:ensure).sync
      end
    end

    it 'for absent calls destroy on the provider' do
      provider = mock 'provider'
      provider.expects(:destroy)

      resource = described_class.new(name: name, ensure: :absent)
      resource.stubs(:provider).returns(provider)
      resource.property(:ensure).sync
    end
  end

  describe '=> group' do
    it 'is a property' do
      expect(described_class.attrtype(:group)).to eq(:property)
    end

    it 'does not be a required property' do
      expect {
        described_class.new(name: name)
      }.not_to raise_error
    end
  end

  describe '.retrive' do
    subject(:resource) { described_class.new(name: name) }

    let(:provider) { mock 'provider' }

    it 'returns the ensure value from the provider' do
      provider.stubs(:ensure).returns(:FOOBAR)
      resource.stubs(:provider).returns(provider)

      expect(resource.property(:ensure).retrieve).to eq(:FOOBAR)
    end

    it 'w/o a providers it is absent' do
      resource.stubs(:provider).returns(nil)

      expect(resource.property(:ensure).retrieve).to eq(:absent)
    end
  end

  describe '.create' do
    subject(:resource) { described_class.new(name: name) }

    let(:provider) { mock 'provider' }

    it 'creates the resource' do
      resource.stubs(:provider).returns(provider)
      provider.expects(:create)

      resource.create
    end
  end

  describe '.activate' do
    subject(:resource) { described_class.new(name: name) }

    let(:provider) { mock 'provider' }

    it 'activates the resource' do
      resource.stubs(:provider).returns(provider)
      resource.stubs(:create)
      provider.expects(:activate)

      resource.activate
    end
  end

  describe '.deactivate' do
    subject(:resource) { described_class.new(name: name) }

    let(:provider) { mock 'provider' }

    it 'deactivated the resource' do
      resource.stubs(:provider).returns(provider)
      provider.stubs(:create)
      provider.expects(:deactivate)

      resource.deactivate
    end
  end
end
