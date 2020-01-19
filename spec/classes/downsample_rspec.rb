require 'spec_helper'

describe 'thanos::downsample' do
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
        is_expected.to contain_thanos__resources__service('downsample').with(
          'ensure'   => 'running',
          'bin_path' => '/usr/local/bin/thanos',
          'params'   => {
            'log.level'                    => 'info',
            'log.format'                   => 'logfmt',
            'tracing.config-file'          => nil,
            'http-address'                 => '0.0.0.0:10902',
            'http-grace-period'            => '2m',
            'data-dir'                     => nil,
            'objstore.config-file'         => nil,
          },
        )
      }
    end
  end
end
