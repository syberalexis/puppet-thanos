require 'spec_helper'

describe 'thanos' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      arch = os.split('-').last
      let(:facts) do
        os_facts.merge('os' => { 'architecture' => arch })
      end

      [
        { version: '0.9.0' },
        {
          version: '0.9.0',
          manage_sidecar: true,
          manage_query: true,
          manage_rule: true,
          manage_store: true,
          manage_compact: true,
          manage_downsample: true,
          download_url: 'https://my-custom-dropbox.com/thanos/releases/thanos-0.9.0.linux.amd64.tar.gz',
          user: 'wheel',
          group: 'wheel',
          usershell: '/bin/bash',
          extra_groups: ['sudo'],
          extract_command: 'tree',
        },
        {
          version: '0.9.0',
          manage_user: false,
          manage_group: false,
        },
        {
          version: '0.9.0',
          install_method: 'package',
          package_ensure: 'present',
          package_name: 'thanos',
        },
      ].each do |parameters|
        context "with parameters #{parameters}" do
          let(:params) do
            parameters
          end

          thanos_os = os_facts[:kernel].downcase
          thanos_arch = (os_facts[:architecture] == 'aarch64') ? 'arm64' : 'amd64'
          thanos_version = parameters[:version]
          thanos_manage_sidecar = parameters[:manage_sidecar] || false
          thanos_manage_query = parameters[:manage_query] || false
          thanos_manage_rule = parameters[:manage_rule] || false
          thanos_manage_store = parameters[:manage_store] || false
          thanos_manage_compact = parameters[:manage_compact] || false
          thanos_manage_downsample = parameters[:manage_downsample] || false
          thanos_install_method = parameters[:install_method] || 'url'
          thanos_download_url = parameters[:download_url] || "https://github.com/thanos-io/thanos/releases/download/v#{thanos_version}/thanos-#{thanos_version}.#{thanos_os}-#{thanos_arch}.tar.gz"
          thanos_package_ensure = parameters[:package_ensure] || 'present'
          thanos_manage_user = parameters[:manage_user].nil? ? true : parameters[:manage_user]
          thanos_manage_group = parameters[:manage_group].nil? ? true : parameters[:manage_user]
          thanos_user = parameters[:user] || 'thanos'
          thanos_group = parameters[:group] || 'thanos'
          thanos_user_shell = parameters[:usershell] || '/bin/false'
          thanos_extra_groups = parameters[:extra_groups] || []
          thanos_extract_command = parameters[:extract_command]

          # Compilation
          it {
            is_expected.to compile
          }

          # Install
          it {
            case thanos_install_method
            when 'url'
              is_expected.to contain_archive("/tmp/thanos-#{thanos_version}.tar.gz").with(
                'ensure'          => 'present',
                'extract'         => true,
                'extract_path'    => '/opt',
                'source'          => thanos_download_url,
                'checksum_verify' => false,
                'creates'         => "/opt/thanos-#{thanos_version}.#{thanos_os}-#{thanos_arch}/thanos",
                'cleanup'         => true,
                'extract_command' => thanos_extract_command,
              )
              is_expected.to contain_file("/opt/thanos-#{thanos_version}.#{thanos_os}-#{thanos_arch}/thanos").with(
                'owner'  => 'root',
                'group'  => '0',
                'mode'   => '0555',
              )
              is_expected.to contain_file('/usr/local/bin/thanos').with(
                'ensure' => 'link',
                'target' => "/opt/thanos-#{thanos_version}.#{thanos_os}-#{thanos_arch}/thanos",
              )
              is_expected.not_to contain_package('thanos')
            when 'package'
              is_expected.not_to contain_archive("/tmp/thanos-#{thanos_version}.tar.gz")
              is_expected.not_to contain_file("/opt/thanos-#{thanos_version}.#{thanos_os}-#{thanos_arch}/thanos")
              is_expected.not_to contain_file('/usr/local/bin/thanos')
              is_expected.to contain_package('thanos').with(
                'ensure' => thanos_package_ensure,
              )
            end

            # User
            if thanos_manage_user
              is_expected.to contain_user(thanos_user).with(
                'ensure' => 'present',
                'system' => true,
                'groups' => [thanos_group] + thanos_extra_groups,
                'shell'  => thanos_user_shell,
              )
            else
              is_expected.not_to contain_user(thanos_user)
            end
            # Group
            if thanos_manage_group
              is_expected.to contain_group(thanos_group).with(
                'ensure' => 'present',
                'system' => true,
              )
            else
              is_expected.not_to contain_group(thanos_group)
            end

            if thanos_manage_sidecar
              is_expected.to contain_class('thanos::sidecar')
            end
            if thanos_manage_query
              is_expected.to contain_class('thanos::query')
            end
            if thanos_manage_rule
              is_expected.to contain_class('thanos::rule')
            end
            if thanos_manage_store
              is_expected.to contain_class('thanos::store')
            end
            if thanos_manage_compact
              is_expected.to contain_class('thanos::compact')
            end
            if thanos_manage_downsample
              is_expected.to contain_class('thanos::downsample')
            end
          }
        end
      end
    end
  end
end
