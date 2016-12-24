require 'spec_helper'
require 'puppet'

describe Puppet::Type.type(:postmulti) do
  let(:name) { 'postfix-foobar' }
  let(:invalid_name) { 'foobar' }

  describe 'namevar' do
    it 'accepts a valid value' do
      expect do
        described_class.new(name: name)
      end.not_to raise_error
    end

    it 'does not accept a invalid name' do
      expect do
        described_class.new(name: invalid_name)
      end.to raise_error(Puppet::Error, %r{Invalid name})
    end
  end

  describe '=> ensure' do
    [:present, :absent, :active, :inactive].each do |value|
      it "should support #{value} as a value to ensure" do
        expect do
          described_class.new(name: name,
                              ensure: value)
        end.not_to raise_error
      end
    end

    it 'does not support other values' do
      expect do
        described_class.new(name: name,
                            ensure: :yolo)
      end.to raise_error(Puppet::Error, %r{Invalid value})
    end

    {
      present: :activate,
      active: :activate,
      inactive: :deactivate
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
      expect do
        described_class.new(name: name)
      end.not_to raise_error
    end
  end

  describe '.retrive' do
    subject { described_class.new(name: name) }
    let(:provider) { mock 'provider' }

    it 'returns the ensure value from the provider' do
      provider.stubs(:ensure).returns(:FOOBAR)
      subject.stubs(:provider).returns(provider)

      expect(subject.property(:ensure).retrieve).to eq(:FOOBAR)
    end

    it 'w/o a providers it is absent' do
      subject.stubs(:provider).returns(nil)

      expect(subject.property(:ensure).retrieve).to eq(:absent)
    end
  end

  describe '.create' do
    subject { described_class.new(name: name) }
    let(:provider) { mock 'provider' }

    it 'creates the resource' do
      subject.stubs(:provider).returns(provider)
      provider.expects(:create)

      subject.create
    end
  end

  describe '.activate' do
    subject { described_class.new(name: name) }
    let(:provider) { mock 'provider' }

    it 'activates the resource' do
      subject.stubs(:provider).returns(provider)
      subject.stubs(:create)
      provider.expects(:activate)

      subject.activate
    end
  end

  describe '.deactivate' do
    subject { described_class.new(name: name) }
    let(:provider) { mock 'provider' }

    it 'deactivated the resource' do
      subject.stubs(:provider).returns(provider)
      provider.stubs(:create)
      provider.expects(:deactivate)

      subject.deactivate
    end
  end
end
