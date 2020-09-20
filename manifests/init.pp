# @summary This module manages Thanos
#
# Init class of Thanos module. It can installes Thanos binaries and manages components as single Service.
#
# @param version
#  Thanos release. See https://github.com/thanos-io/thanos/releases
# @param os
#  Operating system.
# @param manage_sidecar
#  Whether to create a service to run Sidecar.
# @param manage_query
#  Whether to create a service to run Query.
# @param manage_query_frontend
#  Whether to create a service to run Query Frontend.
# @param manage_rule
#  Whether to create a service to run Rule.
# @param manage_store
#  Whether to create a service to run Store.
# @param manage_compact
#  Whether to create a service to run Compact.
# @param manage_receiver
#  Whether to create a service to run Receiver.
# @param manage_tools_bucket_web
#  Whether to create a service to run Bucket Web interface.
# @param install_method
#  Installation method: url or package (only url is supported currently).
# @param package_ensure
#  If package, then use this for package ensure default 'latest'.
# @param package_name
#  Thanos package name - not available yet.
# @param base_url
#  Base URL for thanos.
# @param download_extension
#  Extension of Thanos binaries archive.
# @param download_url
#  Complete URL corresponding to the Thanos release, default to undef.
# @param base_dir
#  Base directory where Thanos is extracted.
# @param bin_dir
#  Directory where binaries are located.
# @param config_dir
#  Directory where configuration are located.
# @param purge_config_dir
#  Purge configuration directory.
# @param tsdb_path
#  Data directory of TSDB.
# @param manage_user
#  Whether to create user for thanos or rely on external code for that.
# @param manage_group
#  Whether to create user for thanos or rely on external code for that.
# @param user
#  User running thanos.
# @param group
#  Group under which thanos is running.
# @param usershell
#  if requested, we create a user for thanos. The default shell is false. It can be overwritten to any valid path.
# @param extra_groups
#  Add other groups to the managed user.
# @param extract_command
#  Custom command passed to the archive resource to extract the downloaded archive.
# @param manage_storage_config
#  Whether to manage storage configuration file.
# @param storage_config_file
#  Path to storage configuration file.
# @param storage_config
#  Storage configuration.
#     type: one of ['S3', 'GCS', 'AZURE', 'SWIFT', 'COS', 'ALIYUNOSS', 'FILESYSTEM']
#     config: storage typed configuration in Hash[String, Data]
# @param manage_tracing_config
#  Whether to manage tracing configuration file
# @param tracing_config_file
#  Path to tracing configuration file.
# @param tracing_config
#  Tracing configuration.
#     type: one of ['JAEGER', 'STACKDRIVER', 'ELASTIC_APM', 'LIGHTSTEP']
#     config: tracing typed configuration in Hash[String, Data]
# @param manage_index_cache_config
#  Whether to manage index cache configuration file
# @param index_cache_config_file
#  Path to index cache configuration file.
# @param index_cache_config
#  Index cache configuration.
#     type: one of ['IN-MEMORY', 'MEMCACHED']
#     config: index cache typed configuration in Hash[String, Data]
# @example
#   include thanos
class thanos (
  Pattern[/\d+\.\d+\.\d+/]            $version,
  String                              $os                        = downcase($facts['kernel']),
  Boolean                             $manage_sidecar            = false,
  Boolean                             $manage_query              = false,
  Boolean                             $manage_query_frontend     = false,
  Boolean                             $manage_rule               = false,
  Boolean                             $manage_store              = false,
  Boolean                             $manage_compact            = false,
  Boolean                             $manage_receive            = false,
  Boolean                             $manage_tools_bucket_web   = false,

  # Installation
  Enum['url', 'package', 'none']      $install_method            = 'url',
  Enum['present', 'absent', 'latest'] $package_ensure            = 'latest',
  String                              $package_name              = 'thanos',
  Stdlib::HTTPUrl                     $base_url                  = 'https://github.com/thanos-io/thanos/releases/download',
  String                              $download_extension        = 'tar.gz',
  Optional[Stdlib::HTTPUrl]           $download_url              = undef,
  Stdlib::Absolutepath                $base_dir                  = '/opt',
  Stdlib::Absolutepath                $bin_dir                   = '/usr/local/bin',
  Stdlib::Absolutepath                $config_dir                = '/etc/thanos',
  Boolean                             $purge_config_dir          = true,
  Stdlib::Absolutepath                $tsdb_path                 = '/data',

  # User Management
  Boolean                             $manage_user               = true,
  Boolean                             $manage_group              = true,
  String                              $user                      = 'thanos',
  String                              $group                     = 'thanos',
  Stdlib::Absolutepath                $usershell                 = '/bin/false',
  Array[String]                       $extra_groups              = [],
  Optional[String]                    $extract_command           = undef,

  # Configuration
  Boolean                             $manage_storage_config     = false,
  Stdlib::Absolutepath                $storage_config_file       = "${config_dir}/storage.yaml",
  Hash[String, Data]                  $storage_config            = {},
  Boolean                             $manage_tracing_config     = false,
  Optional[Stdlib::Absolutepath]      $tracing_config_file       = undef,
  Hash[String, Data]                  $tracing_config            = {},
  Boolean                             $manage_index_cache_config = false,
  Optional[Stdlib::Absolutepath]      $index_cache_config_file   = undef,
  Hash[String, Data]                  $index_cache_config        = {},
) {
  $bin_path = "${bin_dir}/thanos"

  $notify_services = {
    'sidecar'        => $manage_sidecar,
    'query'          => $manage_query,
    'query-frontend' => $manage_query_frontend,
    'rule'           => $manage_rule,
    'store'          => $manage_store,
    'compact'        => $manage_compact,
    'receive'        => $manage_receive,
    'bucket-web'     => $manage_tools_bucket_web,
  }.filter |String $key, Boolean $value| {
    $value
  }.map |String $key, Boolean $value| {
    Service["thanos-${key}"]
  }

  case $facts['architecture'] {
    'x86_64', 'amd64': { $real_arch = 'amd64' }
    'aarch64':         { $real_arch = 'arm64' }
    default:           {
      fail("Unsupported kernel architecture: ${facts['architecture']}")
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
    Class['thanos::config'] -> Class['thanos::sidecar']
  }

  if $manage_query {
    include thanos::query
    Class['thanos::config'] -> Class['thanos::query']
  }

  if $manage_query_frontend {
    include thanos::query_frontend
    Class['thanos::config'] -> Class['thanos::query_frontend']
  }

  if $manage_rule {
    include thanos::rule
    Class['thanos::config'] -> Class['thanos::rule']
  }

  if $manage_store {
    include thanos::store
    Class['thanos::config'] -> Class['thanos::store']
  }

  if $manage_compact {
    include thanos::compact
    Class['thanos::config'] -> Class['thanos::compact']
  }

  if $manage_receive {
    include thanos::receive
    Class['thanos::config'] -> Class['thanos::receive']
  }

  if $manage_tools_bucket_web {
    include thanos::tools::bucket_web
    Class['thanos::config'] -> Class['thanos::tools::bucket_web']
  }
}
