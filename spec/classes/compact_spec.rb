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
          user: 'thanos',
          group: 'thanos',
        }
      end

      it {
        is_expected.to compile
      }

      it {
        is_expected.to contain_thanos__resources__service('compact').with(
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
            'data-dir'                                => nil,
            'objstore.config-file'                    => '/etc/thanos/storage.yaml',
            'consistency-delay'                       => '30m',
            'retention.resolution-raw'                => '0d',
            'retention.resolution-5m'                 => '0d',
            'retention.resolution-1h'                 => '0d',
            'wait'                                    => false,
            'wait-interval'                           => '5m',
            'downsampling.disable'                    => false,
            'block-viewer.global.sync-block-interval' => '1m',
            'compact.concurrency'                     => 1,
            'delete-delay'                            => '48h',
            'selector.relabel-config-file'            => nil,
            'web.external-prefix'                     => nil,
            'web.prefix-header'                       => nil,
            'bucket-web-label'                        => nil,
          },
        )
      }
    end
  end
end
