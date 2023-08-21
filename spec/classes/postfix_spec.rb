require 'spec_helper'

describe 'postfix' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      describe 'with default parameters' do
        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('postfix') }
        it { is_expected.to contain_class('postfix::package') }
        it { is_expected.to contain_class('postfix::config').that_requires('Class[postfix::package]') }
        it { is_expected.to contain_class('postfix::config').that_notifies('Class[postfix::service]') }
        it { is_expected.to contain_class('postfix::service').that_requires('Class[postfix::config]') }

        it { is_expected.to contain_package('postfix') }
        it { is_expected.to contain_package('mailx') }

        it { is_expected.to contain_service('postfix') }
      end

      context 'without mailx management' do
        let(:params) { { mailx_manage: false } }

        it { is_expected.not_to contain_package('mailx') }
      end

      context 'without service management' do
        let(:params) { { service_manage: false } }

        it { is_expected.not_to contain_service('postfix') }
      end

      context 'with version string' do
        let(:params) { { package_ensure: '1.2.3-4.el5' } }

        it { is_expected.to contain_package('postfix').with_ensure('1.2.3-4.el5') }
      end
    end
  end
end
