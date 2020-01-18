# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include thanos
class thanos (
  Pattern[/\d+\.\d+\.\d+/]                        $version,
  String                                          $os                            = downcase($facts['kernel']),
  Boolean                                         $manage_sidecar                = false,
  Boolean                                         $manage_query                  = false,
  Boolean                                         $manage_rule                   = false,
  Boolean                                         $manage_store                  = false,
  Boolean                                         $manage_compact                = false,
  Boolean                                         $manage_downsample             = false,

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
) {
  $bin_path = "${bin_dir}/thanos"

  $notify_services = {
    'sidecar'    => $manage_sidecar,
    'query'      => $manage_query,
    'rule'       => $manage_rule,
    'store'      => $manage_store,
    'compact'    => $manage_compact,
    'downsample' => $manage_downsample,
  }.filter |String $key, Boolean $value| {
    $value
  }.map |String $key, Boolean $value| {
    Service["thanos-${key}"]
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

  include thanos::install
  include thanos::config

  Class['thanos::install'] -> Class['thanos::config']

  if $manage_sidecar {
    include thanos::sidecar
    Class['thanos::install'] -> Class['thanos::sidecar']
  }

  if $manage_query {
    include thanos::query
    Class['thanos::install'] -> Class['thanos::query']
  }

  if $manage_rule {
    include thanos::rule
    Class['thanos::install'] -> Class['thanos::rule']
  }

  if $manage_store {
    include thanos::store
    Class['thanos::install'] -> Class['thanos::store']
  }

  if $manage_compact {
    include thanos::compact
    Class['thanos::install'] -> Class['thanos::compact']
  }

  if $manage_downsample {
    include thanos::downsample
    Class['thanos::install'] -> Class['thanos::downsample']
  }
}
