require 'spec_helper'

describe 'thanos::downsample' do
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
        is_expected.to contain_thanos__resources__service('downsample').with(
          'ensure'   => 'running',
          'bin_path' => '/usr/local/bin/thanos',
          'user'     => 'thanos',
          'group'    => 'thanos',
          'params'   => {
            'log.level'                    => 'info',
            'log.format'                   => 'logfmt',
            'tracing.config-file'          => '/etc/thanos/tracing.yaml',
            'http-address'                 => '0.0.0.0:10902',
            'http-grace-period'            => '2m',
            'data-dir'                     => nil,
            'objstore.config-file'         => '/etc/thanos/storage.yaml',
          },
        )
      }
    end
  end
end
