require 'spec_helper'
require 'puppet'

describe Puppet::Type.type(:postconf) do
  let(:pc_parameter) { 'myhostname' }
  let(:pc_value) { 'foo.bar' }

  describe '=> ensure' do
    [:present, :absent].each do |value|
      it "should support #{value} as a value to ensure" do
        expect {
          described_class.new(name: pc_parameter,
                              ensure: value,
                              value: pc_value)
        }.not_to raise_error
      end
    end

    it 'does not support other values' do
      expect {
        described_class.new(name: pc_parameter,
                            ensure: pc_value,
                            value: pc_value)
      }.to raise_error(Puppet::Error, %r{Invalid value})
    end

    it 'defaults to present' do
      expect(described_class.new(name: pc_parameter,
                                 value: pc_value)[:ensure]).to eq :present
    end
  end

  describe '=> parameter' do
    it 'is a param' do
      expect(described_class.attrtype(:parameter)).to eq(:param)
    end

    it 'is the namevar' do
      expect(described_class.key_attributes).to eq([:parameter])
    end

    describe 'insane looking parameter' do
      %w[2bounce_notice_recipient myhostname virtual_transport smtp_tls_CApath].each do |value|
        it 'accepts sane looking parameter names' do
          expect {
            described_class.new(name: value,
                                value: pc_value)
          }.not_to raise_error
        end
      end
    end

    describe 'insane looking parameter' do
      %w[2bounce__recipient 2bounce_notice_ _notice_recipient].each do |value|
        it "should reject #{value} as value to parameter" do
          expect {
            described_class.new(name: value,
                                value: pc_value)
          }.to raise_error(Puppet::Error, %r{Invalid value})
        end
      end
    end
  end

  describe '=> value' do
    it 'is a property' do
      expect(described_class.attrtype(:value)).to eq(:property)
    end

    it 'accepts a string' do
      expect {
        described_class.new(name:  pc_parameter,
                            value: 'string')
      }.not_to raise_error
    end

    it 'accepts a array of strings' do
      expect {
        described_class.new(name:  pc_parameter,
                            value: %w[string foo bar])
      }.not_to raise_error
    end

    it 'accepts a number' do
      expect {
        described_class.new(name:  pc_parameter,
                            value: 42)
      }.not_to raise_error
    end

    [
      {},
      ['foo', {}],
    ].each do |value|
      it "rejects \"#{value}\"" do
        expect {
          described_class.new(name:  pc_parameter,
                              value: value)
        }.to raise_error(Puppet::Error, %r{Invalid value})
      end
    end

    it 'is a ignored on ensure => absent' do
      expect {
        described_class.new(name: pc_parameter,
                            ensure: :absent)
      }.not_to raise_error
    end

    describe '.should_to_s' do
      subject(:value) { described_class.new(name: pc_parameter, value: pc_value).property(:value) }

      it 'returns a sting as is' do
        expect(value.should_to_s('foo')).to eq('foo')
      end

      it 'returns a singel string array as string' do
        expect(value.should_to_s(['foo'])).to eq('foo')
      end

      it 'returns a string array as comma joined string' do
        expect(value.should_to_s(%w[foo bar])).to eq('foo, bar')
      end
    end

    describe '.is_to_s' do
      subject(:value) { described_class.new(name: pc_parameter, value: pc_value).property(:value) }

      it 'returns a sting as is' do
        expect(value.is_to_s('foo')).to eq('foo')
      end

      it 'returns a singel string array as string' do
        expect(value.is_to_s(['foo'])).to eq('foo')
      end

      it 'returns a string array as comma joined string' do
        expect(value.is_to_s(%w[foo bar])).to eq('foo, bar')
      end
    end
  end
end
