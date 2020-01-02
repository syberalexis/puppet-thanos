# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include thanos
class thanos (
  Pattern[/\d\.\d\.\d/]                           $version,
  Boolean                                         $manage_sidecar                = false,
  Boolean                                         $manage_query                  = false,
  Boolean                                         $manage_rule                   = false,
  Boolean                                         $manage_store                  = false,

  String                                          $os                            = downcase($facts['kernel']),

  # Installation
  Enum['url', 'package', 'none']                  $install_method                = 'url',
  Enum['present', 'absent']                       $package_ensure                = 'present',
  String                                          $package_name                  = 'thanos',
  Stdlib::HTTPUrl                                 $base_url                      = 'https://github.com/thanos-io/thanos/releases/download',
  String                                          $download_extension            = 'tar.gz',
  Optional[Stdlib::HTTPUrl]                       $download_url                  = undef,
  Stdlib::Absolutepath                            $base_dir                      = '/opt',
  Stdlib::Absolutepath                            $bin_dir                       = '/usr/local/bin',
  Stdlib::Absolutepath                            $tsdb_path                     = '/opt/prometheus/data',
  Stdlib::Absolutepath                            $config_dir                    = '/etc/thanos',
  Boolean                                         $purge_config_dir              = true,

  # User Management
  Boolean                                         $manage_user                   = true,
  Boolean                                         $manage_group                  = true,
  String                                          $user                          = 'thanos',
  String                                          $group                         = 'thanos',
  Stdlib::Absolutepath                            $usershell                     = '/bin/false',
  Array[String]                                   $extra_groups                  = [],
  Optional[String]                                $extract_command               = undef,

  # Configuration
  Stdlib::Absolutepath                            $tracing_config_file           = "${config_dir}/tracing.config",
  Hash                                            $tracing_config                = {},
  Optional[Stdlib::Absolutepath]                  $grpc_server_tls_cert          = undef,
  Optional[Stdlib::Absolutepath]                  $grpc_server_tls_key           = undef,
  Optional[Stdlib::Absolutepath]                  $grpc_server_tls_client_ca     = undef,
  Stdlib::Absolutepath                            $reloader_config_file          = "${config_dir}/reloader.config",
  Stdlib::Absolutepath                            $reloader_config_envsubst_file = "${config_dir}/reloader-env.config",
  Array[Stdlib::Absolutepath]                     $reloader_rule_dir             = [],
  Stdlib::Absolutepath                            $objstore_config_file          = "${config_dir}/store.config",
  Hash                                            $objstore_config               = {},
  Enum['debug', 'info', 'warn', 'error', 'fatal'] $log_level                     = 'info',
  Enum['logfmt', 'json']                          $log_format                    = 'logfmt',

  $http_address = '0.0.0.0:10902',
  $http_grace_period = '2m',
  $grpc_address = '0.0.0.0:10901',
  $grpc_grace_period = '2m',
  $prometheus_url = 'http://127.0.0.1:9090',
  $prometheus_ready_timeout = '10m',
  $min_time = '0000-01-01T00:00:00Z',
) {
  $_manage_services = {
    'sidecar' => $manage_sidecar,
    'query'   => $manage_query,
    'rule'    => $manage_rule,
    'store'   => $manage_store,
  }

  case $facts['os']['architecture'] {
    'x86_64', 'amd64': { $real_arch = 'amd64' }
    'aarch64':         { $real_arch = 'arm64' }
    default:           {
      fail("Unsupported kernel architecture: ${facts['os']['architecture']}")
    }
  }

  if $download_url {
    $real_download_url = $download_url
  } else {
    $real_download_url = "${base_url}/v${version}/thanos-${version}.${os}-${real_arch}.${download_extension}"
  }

  $notify_services = $_manage_services.filter |String $key, Boolean $value| {
    $value
  }.map |String $key, Boolean $value| {
      Service["thanos-${key}"]
  }

  include thanos::install
  include thanos::config

  $_manage_services.each |String $key, Boolean $value| {
    if $value {
      class { "thanos::${key}": }
      Class['thanos::install'] -> Class["thanos::${key}"] -> Service["thanos-${key}"]
    }

    $_service_ensure = $value ? {
      true  => running,
      false => absent,
    }
    thanos::service { "thanos-${key}" :
      ensure   => $_service_ensure,
      bin_path => "${bin_dir}/thanos",
      params   => {}
    }
  }

  Class['thanos::install'] -> Class['thanos::config']
}
