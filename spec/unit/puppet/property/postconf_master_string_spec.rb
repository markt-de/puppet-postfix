require 'spec_helper'
require 'puppet'

require 'puppet/property/postconf_master_string'

describe Puppet::Property::PostconfMasterString do
  subject { described_class.new(resource: resource) }
  let(:resource) { mock('resource') }

  describe '.unmunge' do
    it 'munge :undef as -' do
      expect(subject.unmunge(:undef)).to eq('-')
    end

    it 'munge "foo" as "foo"' do
      expect(subject.unmunge('foo')).to eq('foo')
    end
  end

  describe '.property_matches?' do
    [
      ['-', :undef],
      %w(foo foo)
    ].each do |current, desired|
      it "matches #{current} to #{desired.inspect}" do
        expect(subject.property_matches?(current, desired)).to eq(true)
      end
    end

    [
      ['-', 'foo'],
      ['foo', '-']
    ].each do |current, desired|
      it "does not match #{current} to #{desired.inspect}" do
        expect(subject.property_matches?(current, desired)).to eq(false)
      end
    end
  end
end
