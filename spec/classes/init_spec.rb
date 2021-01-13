require 'spec_helper'
describe 'ssl_proxy' do
  on_supported_os.each do |os, facts|
    context "single proxy with default values for all parameters on #{os}" do
      let(:facts) { facts }
      let(:node) { 'test.example.com' }
      it { should contain_ssl_proxy__host('test.example.com') }
    end
    context "multiple proxies with default values for all parameters on #{os}" do
      let(:facts) { facts }
      let(:node) { 'test2.example.com' }
      it { should contain_ssl_proxy__host('test2.example.com') }
      it { should contain_ssl_proxy__host('test3.example.com') }
    end
  end
end
