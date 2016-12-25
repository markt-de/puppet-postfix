require 'spec_helper'
require 'puppet'

require 'puppet/property/postconf_master_boolean'

describe Puppet::Property::PostconfMasterBoolean do
  subject { described_class.new(resource: resource) }
  let(:resource) { mock('resource') }

  describe '.unmunge' do
    [:true, :y].each do |arg|
      it "munge #{arg.inspect} as 'y'" do
        expect(subject.unmunge(arg)).to eq('y')
      end
    end

    [:false, :n].each do |arg|
      it "munge #{arg.inspect} as 'n'" do
        expect(subject.unmunge(arg)).to eq('n')
      end
    end

    it 'munge :undef as -' do
      expect(subject.unmunge(:undef)).to eq('-')
    end
  end

  describe '.property_matches?' do
    [
      ['-', :undef],
      ['y', :true],
      ['y', :y],
      ['n', :false],
      ['n', :n]
    ].each do |current, desired|
      it "matches #{current} to #{desired.inspect}" do
        expect(subject.property_matches?(current, desired)).to eq(true)
      end
    end

    [
      ['-', :true],
      ['-', :false],
      ['y', :false],
      ['y', :f],
      ['n', :true],
      ['n', :t]
    ].each do |current, desired|
      it "does not match #{current} to #{desired.inspect}" do
        expect(subject.property_matches?(current, desired)).to eq(false)
      end
    end
  end
end
