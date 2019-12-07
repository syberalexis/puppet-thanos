# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include thanos::install
class thanos::install (
  $log_level='info',
  $log_format='logfmt',
  $http_address='0.0.0.0:10902',
  $http_grace_period='2m',
  $grpc_address='0.0.0.0:10901',
  $grpc_grace_period='2m',
  $prometheus_url='http://127.0.0.1:9090',
  $prometheus_ready_timeout='10m',
  $tsdb_path='./data',
  $min_time='0000-01-01T00:00:00Z',
  Optional[Stdlib::Absolutepath] $tracing_config_file,
  Optional[Hash] $tracing_config,
  Optional[Stdlib::Absolutepath] $grpc_server_tls_cert,
  Optional[Stdlib::Absolutepath] $grpc_server_tls_key,
  Optional[Stdlib::Absolutepath] $grpc_server_tls_client_ca,
  Optional[Stdlib::Absolutepath] $reloader_config_file,
  Optional[Stdlib::Absolutepath] $reloader_config_envsubst_file,
  Optional[Stdlib::Absolutepath] $reloader_rule_dir,
  Optional[Stdlib::Absolutepath] $objstore_config_file,
  Optional[Hash] $objstore_config,
) {
  assert_private()

  if $thanos::tsdb_path {
    file { $thanos::tsdb_path:
      ensure => 'directory',
      owner  => $thanos::user,
      group  => $thanos::group,
      mode   => '0755',
    }
  }
  case $thanos::install_method {
    'url': {
      archive { "/tmp/thanos-${thanos::version}.${thanos::download_extension}":
        ensure          => present,
        extract         => true,
        extract_path    => '/opt',
        source          => $thanos::real_download_url,
        checksum_verify => false,
        creates         => "/opt/thanos-${thanos::version}.${thanos::os}-${thanos::real_arch}/thanos",
        cleanup         => true,
        extract_command => $thanos::extract_command,
      }
      -> file {
        "/opt/thanos-${thanos::version}.${thanos::os}-${thanos::real_arch}/thanos":
          owner => 'root',
          group => 0, # 0 instead of root because OS X uses "wheel".
          mode  => '0555';
        "${thanos::bin_dir}/thanos":
          ensure => link,
          notify => $thanos::notify_service,
          target => "/opt/thanos-${thanos::version}.${thanos::os}-${thanos::real_arch}/thanos";
        "${thanos::bin_dir}/promtool":
          ensure => link,
          target => "/opt/thanos-${thanos::version}.${thanos::os}-${thanos::real_arch}/promtool";
        $thanos::shared_dir:
          ensure => directory,
          owner  => $thanos::user,
          group  => $thanos::group,
          mode   => '0755';
        "${thanos::shared_dir}/consoles":
          ensure => link,
          notify => $thanos::notify_service,
          target => "/opt/thanos-${thanos::version}.${thanos::os}-${thanos::real_arch}/consoles";
        "${thanos::shared_dir}/console_libraries":
          ensure => link,
          notify => $thanos::notify_service,
          target => "/opt/thanos-${thanos::version}.${thanos::os}-${thanos::real_arch}/console_libraries";
      }
    }
    'package': {
      package { $thanos::package_name:
        ensure => $thanos::package_ensure,
        notify => $thanos::notify_service,
      }
      if $thanos::manage_user {
        User[$thanos::user] -> Package[$thanos::package_name]
      }
    }
    'none': {}
    default: {
      fail("The provided install method ${thanos::install_method} is invalid")
    }
  }
  if $thanos::manage_user {
    ensure_resource('user', [ $thanos::user ], {
      ensure => 'present',
      system => true,
      groups => $thanos::extra_groups,
      shell  => $thanos::usershell,
    })

    if $thanos::manage_group {
      Group[$thanos::group] -> User[$thanos::user]
    }
  }
  if $thanos::manage_group {
    ensure_resource('group', [ $thanos::group ],{
      ensure => 'present',
      system => true,
    })
  }
  file { $thanos::config_dir:
    ensure  => 'directory',
    owner   => 'root',
    group   => $thanos::group,
    purge   => $thanos::purge_config_dir,
    recurse => $thanos::purge_config_dir,
  }
}
