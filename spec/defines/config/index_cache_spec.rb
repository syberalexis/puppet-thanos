require 'spec_helper'

describe 'thanos::config::index_cache' do
  let(:title) { '/etc/thanos/index_cache.yaml' }

  [
    {
      ensure: 'present',
      type: 'IN-MEMORY',
      config: {
        test: 'test',
      },
    },
    {
      ensure: 'present',
      type: 'MEMCACHED',
      config: {
        test: 'test',
      },
    },
  ].each do |parameters|
    context "with parameters #{parameters}" do
      let(:params) do
        parameters
      end

      on_supported_os.each do |os, os_facts|
        context "on #{os}" do
          let(:facts) { os_facts }

          it {
            is_expected.to compile
          }

          it {
            is_expected.to contain_file('/etc/thanos/index_cache.yaml').with(
              'ensure' => 'file',
            )
          }
        end
      end
    end
  end
end
