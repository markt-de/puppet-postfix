require 'spec_helper'
require 'puppet'

require 'puppet/type/postconf_master'

describe PostconfMasterString do
  subject(:property) { described_class.new(resource: resource) }

  let(:resource) { double('resource') }

  describe '.munge' do
    it 'munge :undef as -' do
      expect(property.munge(:undef)).to eq('-')
    end

    ['foo', 'foo bar', '{ foo bar }', 'true', 'yes', 'false', 'no', 'y', 'n'].each do |arg|
      it "munge #{arg.inspect} as #{arg.to_s.inspect}" do
        expect(property.munge(arg)).to eq(arg)
      end
    end
  end
end
