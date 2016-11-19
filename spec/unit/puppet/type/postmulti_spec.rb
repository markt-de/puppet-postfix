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

    it 'handles present as actvie' do
      expect(described_class.new(name: name,
                                 ensure: :present)[:ensure]).to eq :active
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
end
