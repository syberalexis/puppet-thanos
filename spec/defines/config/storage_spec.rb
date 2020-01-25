require 'spec_helper'

describe 'thanos::config::storage' do
  let(:title) { '/etc/thanos/storage.yaml' }

  [
    {
      ensure: 'present',
      type: 'FILESYSTEM',
      config: {
        test: 'test',
      },
    },
    {
      ensure: 'present',
      type: 'S3',
      config: {
        test: 'test',
      },
    },
    {
      ensure: 'present',
      type: 'GCS',
      config: {
        test: 'test',
      },
    },
    {
      ensure: 'present',
      type: 'AZURE',
      config: {
        test: 'test',
      },
    },
    {
      ensure: 'present',
      type: 'SWIFT',
      config: {
        test: 'test',
      },
    },
    {
      ensure: 'present',
      type: 'COS',
      config: {
        test: 'test',
      },
    },
    {
      ensure: 'present',
      type: 'ALIYUNOSS',
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
            is_expected.to contain_file('/etc/thanos/storage.yaml').with(
              'ensure' => 'file',
            )
          }
        end
      end
    end
  end
end
