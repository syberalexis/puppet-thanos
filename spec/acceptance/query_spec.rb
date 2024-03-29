require 'spec_helper_acceptance'

describe 'Check idempotence' do
  context 'should work with no errors' do
    pp = <<-EOS
      class { 'thanos': }
      class { 'thanos::query':
        endpoints => [
          'sidecar:10902'
        ],
      }
    EOS

    apply_manifest(pp, 'catch_failures' => true)
    apply_manifest(pp, 'catch_changes' => true)

    describe file('/usr/local/bin/thanos') do
      it { is_expected.to exist }
    end
  end
end
