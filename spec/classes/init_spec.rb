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
    context "redirect with default values for all parameters on #{os}" do
      let(:facts) { facts }
      let(:node) { 'forward.example.com' }
      it { should contain_ssl_proxy__redirect('forward.example.com') }
    end
    context "invalid redirect with default values for all parameters on #{os}" do
      let(:facts) { facts }
      let(:node) { 'invalid-redirect.example.com' }
      it { should compile.and_raise_error(/The redirect target should start with 'https:\/\/'./) }
    end
  end
end
