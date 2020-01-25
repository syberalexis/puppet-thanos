require 'spec_helper'

describe 'thanos::config::tracing' do
  let(:title) { '/etc/thanos/tracing.yaml' }

  [
    {
      ensure: 'present',
      type: 'JAEGER',
      config: {
        test: 'test',
      },
    },
    {
      ensure: 'present',
      type: 'STACKDRIVER',
      config: {
        test: 'test',
      },
    },
    {
      ensure: 'present',
      type: 'ELASTIC_APM',
      config: {
        test: 'test',
      },
    },
    {
      ensure: 'present',
      type: 'LIGHTSTEP',
      config: {
        test: 'test',
      },
    },
  ].each do |parameters|
    context "with parameters #{parameters}" do
      let(:params) do
        parameters
      end

      on_supported_os.each do |os, os_facts|
        context "on #{os}" do
          let(:facts) { os_facts }

          it {
            is_expected.to compile
          }

          it {
            is_expected.to contain_file('/etc/thanos/tracing.yaml').with(
              'ensure' => 'file',
            )
          }
        end
      end
    end
  end
end
