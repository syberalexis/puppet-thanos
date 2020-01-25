require 'spec_helper'

describe 'thanos::compact' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          bin_path: '/usr/local/bin/thanos',
          tracing_config_file: '/etc/thanos/tracing.yaml',
          objstore_config_file: '/etc/thanos/storage.yaml',
        }
      end

      it {
        is_expected.to compile
      }

      it {
        is_expected.to contain_thanos__resources__service('compact').with(
          'ensure'   => 'running',
          'bin_path' => '/usr/local/bin/thanos',
          'params'   => {
            'log.level'                    => 'info',
            'log.format'                   => 'logfmt',
            'tracing.config-file'          => '/etc/thanos/tracing.yaml',
            'http-address'                 => '0.0.0.0:10902',
            'http-grace-period'            => '2m',
            'data-dir'                     => nil,
            'objstore.config-file'         => '/etc/thanos/storage.yaml',
            'consistency-delay'            => '30m',
            'retention.resolution-raw'     => '0d',
            'retention.resolution-5m'      => '0d',
            'retention.resolution-1h'      => '0d',
            'wait'                         => false,
            'downsampling.disable'         => false,
            'block-sync-concurrency'       => 20,
            'compact.concurrency'          => 1,
            'selector.relabel-config-file' => nil,
          },
        )
      }
    end
  end
end
