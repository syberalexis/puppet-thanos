require 'spec_helper'

describe 'thanos::query_frontend' do
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
        is_expected.to contain_thanos__resources__service('query-frontend').with(
          'ensure'   => 'running',
          'bin_path' => '/usr/local/bin/thanos',
          'user'     => 'thanos',
          'group'    => 'thanos',
          'params'   => {
            'log.level'                                => 'info',
            'log.format'                               => 'logfmt',
            'tracing.config-file'                      => '/etc/thanos/tracing.yaml',
            'query-range.split-interval'               => '24h',
            'query-range.max-retries-per-request'      => 5,
            'query-range.max-query-length'             => 0,
            'query-range.max-query-parallelism'        => 14,
            'query-range.response-cache-max-freshness' => '1m',
            'query-range.partial-response'             => false,
            'query-range.response-cache-config-file'   => nil,
            'http-address'                             => '0.0.0.0:10902',
            'http-grace-period'                        => '2m',
            'query-frontend.downstream-url'            => 'http://localhost:9090',
            'query-frontend.compress-responses'        => false,
            'query-frontend.log-queries-longer-than'   => "0",
            'log.request.decision'                     => nil,
          },
        )
      }
    end
  end
end
