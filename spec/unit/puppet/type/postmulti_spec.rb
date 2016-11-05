require 'spec_helper'
require 'puppet'

describe Puppet::Type::type(:postmulti) do

  let(:name) { 'postfix-foobar' }
  let(:invalid_name) { 'foobar' }

  describe 'namevar' do
    it 'should accept a valid value' do
      expect { described_class.new({
        :name   => name,
      })}.to_not raise_error
    end

    it 'should not accept a invalid name' do
      expect {  described_class.new({
        :name   => invalid_name,
      })}.to raise_error(Puppet::Error, /Invalid name/)
    end
  end

  describe '=> ensure' do
    [ :present, :absent, :active, :inactive ].each do |value|
      it "should support #{value} as a value to ensure" do
        expect { described_class.new({
          :name   => name,
          :ensure => value,
        })}.to_not raise_error
      end
    end

    it 'should not support other values' do
      expect {  described_class.new({
        :name   => name,
        :ensure => :yolo,
      })}.to raise_error(Puppet::Error, /Invalid value/)
    end

    it 'should handle present as actvie' do
      expect( described_class.new({
        :name   => name,
        :ensure => :present
      })[:ensure]).to eq :active
    end
  end

  describe '=> group' do
    it 'should be a property' do
      expect(described_class.attrtype(:group)).to eq(:property)
    end

    it 'should not be a required property' do
      expect {  described_class.new({
        :name   => name,
      })}.not_to raise_error
    end
  end

end
