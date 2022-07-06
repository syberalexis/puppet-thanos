require 'spec_helper'

describe 'thanos::query' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          bin_path: '/usr/local/bin/thanos',
          tracing_config_file: '/etc/thanos/tracing.yaml',
          user: 'thanos',
          group: 'thanos',
        }
      end

      it {
        is_expected.to compile
      }

      it {
        is_expected.to contain_thanos__resources__service('query').with(
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
            'grpc-client-tls-secure'            => false,
            'grpc-client-tls-cert'              => nil,
            'grpc-client-tls-key'               => nil,
            'grpc-client-tls-ca'                => nil,
            'grpc-client-server-name'           => nil,
            'web.route-prefix'                  => nil,
            'web.external-prefix'               => nil,
            'web.prefix-header'                 => nil,
            'log.request.decision'              => nil,
            'query.timeout'                     => '2m',
            'query.max-concurrent'              => 20,
            'query.loopback-delta'              => nil,
            'query.max-concurrent-select'       => 4,
            'query.replica-label'               => nil,
            'selector-label'                    => [],
            'endpoint'                          => [],
            'store-strict'                      => nil,
            'store.sd-files'                    => [],
            'store.sd-interval'                 => '5m',
            'store.sd-dns-interval'             => '30s',
            'store.unhealthy-timeout'           => '30s',
            'query.auto-downsampling'           => false,
            'query.partial-response'            => false,
            'query.default-evaluation-interval' => '1m',
            'store.response-timeout'            => '0ms',
          },
        )
      }
    end
  end
end
