require 'spec_helper'

describe 'postfix' do
  describe 'with default values for all parameters' do
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_class('postfix') }

    it { is_expected.to contain_class('postfix::package') }

    it { is_expected.to contain_class('postfix::service').that_requires('Class[postfix::package]') }
  end
end
