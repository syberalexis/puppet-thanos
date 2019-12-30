require 'spec_helper'

describe 'thanos' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      arch = os.split('-').last
      let(:facts) do
        os_facts.merge('os' => { 'architecture' => arch })
      end
      let(:params) do
        { 'version' => '0.9.0' }
      end

      it { is_expected.to compile }
    end
  end
end
