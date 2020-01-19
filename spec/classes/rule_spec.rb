require 'spec_helper'

describe 'thanos::rule' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          bin_path: '/usr/local/bin/thanos',
        }
      end

      it {
        is_expected.to compile
      }

      it {
        is_expected.to contain_thanos__resources__service('rule').with(
          'ensure'   => 'running',
          'bin_path' => '/usr/local/bin/thanos',
          'params'   => {
            'log.level'                  => 'info',
            'log.format'                 => 'logfmt',
            'tracing.config-file'        => nil,
            'http-address'               => '0.0.0.0:10902',
            'http-grace-period'          => '2m',
            'grpc-address'               => '0.0.0.0:10901',
            'grpc-grace-period'          => '2m',
            'grpc-server-tls-cert'       => nil,
            'grpc-server-tls-key'        => nil,
            'grpc-server-tls-client-ca'  => nil,
            'label'                      => [],
            'data-dir'                   => nil,
            'rule-file'                  => [],
            'resend-delay'               => '1m',
            'eval-interval'              => '30s',
            'tsdb.block-duration'        => '2h',
            'tsdb.retention'             => '48h',
            'alertmanagers.url'          => [],
            'alertmanagers.send-timeout' => '10s',
            'alert.query-url'            => nil,
            'alert.label-drop'           => [],
            'web.route-prefix'           => nil,
            'web.external-prefix'        => nil,
            'web.prefix-header'          => nil,
            'objstore.config-file'       => nil,
            'query'                      => [],
            'query.sd-files'             => [],
            'query.sd-interval'          => '5m',
            'query.sd-dns-interval'      => '30s',
          },
        )
      }
    end
  end
end
