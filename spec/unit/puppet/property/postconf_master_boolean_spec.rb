require 'spec_helper'
require 'puppet'

require 'puppet/type/postconf_master'

describe PostconfMasterBoolean do
  subject { described_class.new(resource: resource) }

  let(:resource) { mock('resource') }

  describe '.munge' do
    [true, :true, 'true', :yes, 'yes', :y, 'y', 'TrUe', 'yEs', 'Y'].each do |arg| # rubocop:disable Lint/BooleanSymbol
      it "munge #{arg.inspect} as 'y'" do
        expect(subject.munge(arg)).to eq('y')
      end
    end

    [false, :false, 'false', :no, 'no', :n, 'n', 'FaLSE', 'nO', 'N'].each do |arg| # rubocop:disable Lint/BooleanSymbol
      it "munge #{arg.inspect} as 'n'" do
        expect(subject.munge(arg)).to eq('n')
      end
    end

    [nil, :undef, '-'].each do |arg|
      it "munge #{arg.inspect} as '-'" do
        expect(subject.munge(arg)).to eq('-')
      end
    end
  end
end
