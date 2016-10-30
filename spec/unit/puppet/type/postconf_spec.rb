require 'spec_helper'
require 'puppet'

describe Puppet::Type::type(:postconf) do

  let(:pc_parameter) { 'myhostname' }
  let(:pc_value) { 'foo.bar' }

  describe '=> ensure' do
    [ :present, :absent ].each do |value|
      it "should support #{value} as a value to ensure" do
        expect { described_class.new({
          :name   => pc_parameter,
          :ensure => value,
          :value  => pc_value,
        })}.to_not raise_error
      end
    end

    it 'should not support other values' do
      expect {  described_class.new({
        :name   => pc_parameter,
        :ensure => pc_value,
        :value  => pc_value,
      })}.to raise_error(Puppet::Error, /Invalid value/)
    end

    it 'should default to present' do
      expect( described_class.new({
        :name   => pc_parameter,
        :value  => pc_value,
      })[:ensure]).to eq :present
    end
  end

  describe '=> parameter' do
    it 'should be a param' do
      expect(described_class.attrtype(:parameter)).to eq(:param)
    end

    it 'should be the namevar' do
      expect(described_class.key_attributes).to eq([:parameter])
    end

    describe 'insane looking parameter' do
      [ '2bounce_notice_recipient', 'myhostname', 'virtual_transport', 'smtp_tls_CApath' ].each do |value|
        it 'should accept sane looking parameter names' do
          expect { described_class.new({
            :name   => value,
            :value  => pc_value,
          })}.to_not raise_error
        end
      end
    end

    describe 'insane looking parameter' do
      [ '2bounce__recipient', '2bounce_notice_', '_notice_recipient' ].each do |value|
        it "should reject #{value} as value to parameter" do
          expect { described_class.new({
            :name   => value,
            :value  => pc_value,
          })}.to raise_error(Puppet::Error, /Invalid value/)
        end
      end
    end
  end

  describe '=> value' do
    it 'should be a property' do
      expect(described_class.attrtype(:value)).to eq(:property)
    end


    it 'should be a required property' do
      expect {  described_class.new({
        :name   => pc_parameter,
        :ensure => :present,
      })}.to raise_error(Puppet::Error, /required/)
    end

    it 'should be a ignored on ensure => absent' do
      expect {  described_class.new({
        :name   => pc_parameter,
        :ensure => :absent,
      })}.to_not raise_error
    end
  end

  describe '=> config_dir' do
    it 'should be a param' do
      expect(described_class.attrtype(:config_dir)).to eq(:param)
    end
  end

end
