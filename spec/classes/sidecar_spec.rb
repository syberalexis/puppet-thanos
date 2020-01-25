require 'spec_helper'

describe 'thanos::sidecar' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          bin_path: '/usr/local/bin/thanos',
          tsdb_path: '/opt/prometheus/data',
          tracing_config_file: '/etc/thanos/tracing.yaml',
        }
      end

      it {
        is_expected.to compile
      }

      it {
        is_expected.to contain_thanos__resources__service('sidecar').with(
          'ensure'   => 'running',
          'bin_path' => '/usr/local/bin/thanos',
          'params'   => {
            'log.level'                     => 'info',
            'log.format'                    => 'logfmt',
            'tracing.config-file'           => '/etc/thanos/tracing.yaml',
            'http-address'                  => '0.0.0.0:10902',
            'http-grace-period'             => '2m',
            'grpc-address'                  => '0.0.0.0:10901',
            'grpc-grace-period'             => '2m',
            'grpc-server-tls-cert'          => nil,
            'grpc-server-tls-key'           => nil,
            'grpc-server-tls-client-ca'     => nil,
            'prometheus.url'                => 'http://localhost:9090',
            'prometheus.ready_timeout'      => '10m',
            'tsdb.path'                     => '/opt/prometheus/data',
            'reloader.config-file'          => nil,
            'reloader.config-envsubst-file' => nil,
            'reloader.rule-dir'             => [],
            'objstore.config-file'          => nil,
            'min-time'                      => nil,
          },
        )
      }
    end
  end
end
