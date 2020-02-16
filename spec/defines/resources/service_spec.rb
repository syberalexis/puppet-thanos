require 'spec_helper'

describe 'thanos::resources::service' do
  let(:title) { 'component' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'ensure running zero params' do
        let(:params) do
          {
            ensure: 'running',
            bin_path: '/usr/local/bin/thanos',
            user: 'thanos',
            group: 'thanos',
          }
        end

        it {
          is_expected.to compile
        }
        it {
          is_expected.to contain_file('/lib/systemd/system/thanos-component.service').with(
            'ensure' => 'file',
          ).with_content(
            "# THIS FILE IS MANAGED BY PUPPET
[Unit]
Description=Thanos component module service
After=network-online.target
Wants=network-online.target

[Service]
User=thanos
Group=thanos
ExecStart=/usr/local/bin/thanos component \\

Restart=always

[Install]
WantedBy=multi-user.target
",
          )

          is_expected.to contain_service('thanos-component').with(
            'ensure' => 'running',
            'enable' => true,
          )
        }
      end

      context 'ensure running with params' do
        let(:params) do
          {
            ensure: 'running',
            bin_path: '/usr/local/bin/thanos',
            user: 'thanos',
            group: 'thanos',
            params: {
              simple: 'test',
              is_true: true,
              is_false: false,
              complex: [1, 2, 3],
            },
          }
        end

        it {
          is_expected.to compile
        }
        it {
          is_expected.to contain_file('/lib/systemd/system/thanos-component.service').with(
            'ensure' => 'file',
          ).with_content(
            "# THIS FILE IS MANAGED BY PUPPET
[Unit]
Description=Thanos component module service
After=network-online.target
Wants=network-online.target

[Service]
User=thanos
Group=thanos
ExecStart=/usr/local/bin/thanos component \\
  --simple=test \\
  --is_true \\
  --complex=1 \\
  --complex=2 \\
  --complex=3
Restart=always

[Install]
WantedBy=multi-user.target
",
          )

          is_expected.to contain_service('thanos-component').with(
            'ensure' => 'running',
            'enable' => true,
          )
        }
      end

      context 'ensure stopped' do
        let(:params) do
          {
            ensure: 'stopped',
            bin_path: '/usr/local/bin/thanos',
            user: 'thanos',
            group: 'thanos',
          }
        end

        it {
          is_expected.to compile
        }
        it {
          is_expected.to contain_file('/lib/systemd/system/thanos-component.service').with(
            'ensure' => 'file',
          ).with_content(
            "# THIS FILE IS MANAGED BY PUPPET
[Unit]
Description=Thanos component module service
After=network-online.target
Wants=network-online.target

[Service]
User=thanos
Group=thanos
ExecStart=/usr/local/bin/thanos component \\

Restart=always

[Install]
WantedBy=multi-user.target
",
          )

          is_expected.to contain_service('thanos-component').with(
            'ensure' => 'stopped',
            'enable' => true,
          )
        }
      end

      context 'ensure absent' do
        let(:params) do
          {
            ensure: 'absent',
            bin_path: '/usr/local/bin/thanos',
            user: 'thanos',
            group: 'thanos',
          }
        end

        it {
          is_expected.to compile
        }
        it {
          is_expected.to contain_file('/lib/systemd/system/thanos-component.service').with(
            'ensure' => 'absent',
          )

          is_expected.to contain_service('thanos-component').with(
            'ensure' => 'stopped',
            'enable' => true,
          )
        }
      end
    end
  end
end
