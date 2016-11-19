require 'spec_helper'

describe 'postfix' do
  context 'postfix::service' do
    describe 'with default values for all parameters' do
      it { is_expected.to contain_service('postfix') }
    end

    context 'w/o service management' do
      let(:params) { { service_manage: false } }

      it { is_expected.not_to contain_service('postfix') }
    end
  end
end
