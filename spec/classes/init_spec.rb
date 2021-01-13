require 'spec_helper'
describe 'ssl_proxy' do
  on_supported_os.each do |os, facts|
    context "with default values for all parameters on #{os}" do
      let(:facts) { facts }
      let(:node) { 'test.example.com' }
      it { should contain_ssl_proxy__host('test.example.com') }
    end
  end
end
