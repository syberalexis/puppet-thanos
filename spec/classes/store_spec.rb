require 'spec_helper'

describe 'thanos::store' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          bin_path: '/usr/local/bin/thanos',
          tracing_config_file: '/etc/thanos/tracing.yaml',
          objstore_config_file: '/etc/thanos/storage.yaml',
          user: 'thanos',
          group: 'thanos',
        }
      end

      it {
        is_expected.to compile
      }

      it {
        is_expected.to contain_thanos__resources__service('store').with(
          'ensure'   => 'running',
          'bin_path' => '/usr/local/bin/thanos',
          'user'     => 'thanos',
          'group'    => 'thanos',
          'params'   => {
            'log.level'                         => 'info',
            'log.format'                        => 'logfmt',
            'tracing.config-file'               => '/etc/thanos/tracing.yaml',
            'http-address'                      => '0.0.0.0:10902',
            'http-grace-period'                 => '2m',
            'grpc-address'                      => '0.0.0.0:10901',
            'grpc-grace-period'                 => '2m',
            'grpc-server-tls-cert'              => nil,
            'grpc-server-tls-key'               => nil,
            'grpc-server-tls-client-ca'         => nil,
            'data-dir'                          => nil,
            'index-cache.config-file'           => nil,
            'index-cache-size'                  => '250MB',
            'chunk-pool-size'                   => '2GB',
            'store.grpc.series-sample-limit'    => 0,
            'store.grpc.series-max-concurrency' => 20,
            'objstore.config-file'              => '/etc/thanos/storage.yaml',
            'sync-block-duration'               => '3m',
            'block-sync-concurrency'            => 20,
            'min-time'                          => nil,
            'max-time'                          => nil,
            'selector.relabel-config-file'      => nil,
            'consistency-delay'                 => '30m',
            'ignore-deletion-marks-delay'       => '24h',
            'web.external-prefix'               => nil,
            'web.prefix-header'                 => nil,
          },
        )
      }
    end
  end
end
