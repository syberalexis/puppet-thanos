require 'spec_helper'

describe 'thanos::receive' do
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
        is_expected.to contain_thanos__resources__service('receive').with(
          'ensure'   => 'running',
          'bin_path' => '/usr/local/bin/thanos',
          'user'     => 'thanos',
          'group'    => 'thanos',
          'params'   => {
            'log.level'                               => 'info',
            'log.format'                              => 'logfmt',
            'tracing.config-file'                     => '/etc/thanos/tracing.yaml',
            'http-address'                            => '0.0.0.0:10902',
            'http-grace-period'                       => '2m',
            'grpc-address'                            => '0.0.0.0:10901',
            'grpc-grace-period'                       => '2m',
            'grpc-server-tls-cert'                    => nil,
            'grpc-server-tls-key'                     => nil,
            'grpc-server-tls-client-ca'               => nil,
            'remote-write.address'                    => '0.0.0.0:19291',
            'remote-write.server-tls-cert'            => nil,
            'remote-write.server-tls-key'             => nil,
            'remote-write.server-tls-client-ca'       => nil,
            'remote-write.client-tls-cert'            => nil,
            'remote-write.client-tls-key'             => nil,
            'remote-write.client-tls-ca'              => nil,
            'remote-write.client-server-name'         => nil,
            'data-dir'                                => nil,
            'objstore.config-file'                    => '/etc/thanos/storage.yaml',
            'tsdb.retention'                          => '15d',
            'receive.hashrings-file'                  => nil,
            'receive.hashrings-file-refresh-interval' => '5m',
            'receive.local-endpoint'                  => nil,
            'receive.tenant-header'                   => 'THANOS-TENANT',
            'receive.default-tenant-id'               => 'default-tenant',
            'receive.tenant-label-name'               => 'tenant_id',
            'receive.replica-header'                  => 'THANOS-REPLICA',
            'receive.replication-factor'              => 1,
            'tsdb.wal-compression'                    => false,
            'tsdb.no-lockfile'                        => false,
          },
        )
      }
    end
  end
end
