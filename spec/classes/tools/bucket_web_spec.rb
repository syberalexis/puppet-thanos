require 'spec_helper'

describe 'thanos::tools::bucket_web' do
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
        is_expected.to contain_thanos__resources__service('bucket-web').with(
          'ensure'   => 'running',
          'bin_path' => '/usr/local/bin/thanos',
          'name'     => 'tools bucket web',
          'user'     => 'thanos',
          'group'    => 'thanos',
          'params'   => {
            'log.level'            => 'info',
            'log.format'           => 'logfmt',
            'tracing.config-file'  => '/etc/thanos/tracing.yaml',
            'objstore.config-file' => '/etc/thanos/storage.yaml',
            'http-address'         => '0.0.0.0:10902',
            'http-grace-period'    => '2m',
            'web.external-prefix'  => '',
            'web.prefix-header'    => '',
            'refresh'              => '30m',
            'timeout'              => '5m',
            'label'                => '',
          },
        )
      }
    end
  end
end
