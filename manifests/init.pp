# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include thanos
class thanos (
  Pattern[/\d\.\d\.\d/] $version,

  String                          $package_name       = 'thanos',
  Enum['info', 'debug'] $log_level = 'info',
  Enum['logfmt'] $log_format = 'logfmt',
  $http_address = '0.0.0.0:10902',
  $http_grace_period = '2m',
  $grpc_address = '0.0.0.0:10901',
  $grpc_grace_period = '2m',
  $prometheus_url = 'http://127.0.0.1:9090',
  $prometheus_ready_timeout = '10m',
  $min_time = '0000-01-01T00:00:00Z',

  Boolean $manage_sidecar = false,
  Boolean $manage_querier = false,
  Boolean $manage_ruler   = false,


  Optional[Stdlib::HTTPUrl]       $download_url       = undef,
  String                          $os                 = downcase($facts['kernel']),

  # Installation
  Enum['present', 'absent']       $package_ensure     = 'present',
  Enum['url', 'package', 'none']  $install_method     = 'url',
  String                          $download_extension = 'tar.gz',
  Stdlib::Absolutepath            $base_dir           = '/opt',
  Stdlib::Absolutepath            $bin_dir            = '/usr/local/bin',
  Stdlib::Absolutepath            $tsdb_path          = '/opt/prometheus/data',
  Stdlib::Absolutepath            $config_dir         = '/etc/thanos',
  Boolean                         $purge_config_dir   = true,

  # User Management
  Boolean                         $manage_user        = true,
  Boolean                         $manage_group       = true,
  String                          $user               = 'thanos',
  String                          $group              = 'thanos',
  Stdlib::Absolutepath            $usershell          = '/bin/false',
  Array[String]                   $extra_groups       = [],
  Optional[String]                $extract_command    = undef,


  Optional[Stdlib::Absolutepath]  $tracing_config_file = undef,
  Optional[Hash]                  $tracing_config = undef,
  Optional[Stdlib::Absolutepath]  $grpc_server_tls_cert = undef,
  Optional[Stdlib::Absolutepath]  $grpc_server_tls_key = undef,
  Optional[Stdlib::Absolutepath]  $grpc_server_tls_client_ca = undef,
  Optional[Stdlib::Absolutepath]  $reloader_config_file = undef,
  Optional[Stdlib::Absolutepath]  $reloader_config_envsubst_file = undef,
  Optional[Stdlib::Absolutepath]  $reloader_rule_dir = undef,
  Optional[Stdlib::Absolutepath]  $objstore_config_file = undef,
  Optional[Hash]                  $objstore_config = undef,

) {
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
    $real_download_url = "https://github.com/thanos-io/thanos/releases/download/v${version}/thanos-${version}.${os}-${real_arch}.${download_extension}"
  }
  $notify_service = Service['thanos']

  include thanos::install
  include thanos::config
  include thanos::service


  Class['thanos::install'] -> Class['thanos::config'] -> Class['thanos::service']

  if $manage_sidecar {
    include thanos::sidecar
    Class['thanos::install'] -> Class['thanos::sidecar']
  }

  if $manage_querier {
    include thanos::querier
    Class['thanos::install'] -> Class['thanos::querier']
  }

  if $manage_ruler {
    include thanos::ruler
    Class['thanos::install'] -> Class['thanos::ruler']
  }
}
