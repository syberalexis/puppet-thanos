require 'spec_helper_acceptance'

describe 'Check idempotence' do
  context 'should work with no errors' do
    pp = <<-EOS
      class{ 'thanos':
        manage_downsample => true,
        manage_storage_config => true,
        storage_config => {
          ensure => 'present',
          type   => 'FILESYSTEM',
          config => {
            directory => '/data'
          }
        }
      }
    EOS

    apply_manifest(pp, 'catch_failures' => true)
    apply_manifest(pp, 'catch_changes' => true)

    describe file('/usr/local/bin/thanos') do
      it { is_expected.to exist }
    end
  end
end
